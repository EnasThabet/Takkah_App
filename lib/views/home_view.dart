import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:takkeh/views/cities_page.dart';
import 'package:takkeh/views/my_account_page.dart';
import 'dart:math';
import 'dart:ui' as ui;
import '../controllers/province_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  String? selectedProvince;
  List<String> provinces = [];
  List<String> filteredProvinces = [];
  bool showList = false;

  final ProvinceController controller = ProvinceController();
  final TextEditingController searchCtrl = TextEditingController();

  late AnimationController _spiralController;
  late AnimationController _entryController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimationFirst;
  late Animation<Offset> _slideAnimationSecond;

  late ui.Image carImage;
  bool isImageLoaded = false;

  @override
  void initState() {
    super.initState();
    loadProvinces();
    loadCarImage();

    _spiralController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeIn),
    );

    _slideAnimationFirst = Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entryController, curve: Curves.easeOut));
    _slideAnimationSecond = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entryController, curve: Curves.easeOut));

    _entryController.forward();

    searchCtrl.addListener(() {
      final query = searchCtrl.text;
      filteredProvinces = provinces
          .where((p) => p.toLowerCase().contains(query.toLowerCase()))
          .toList();
      setState(() {});
    });
  }

  Future<void> loadProvinces() async {
    provinces = await controller.getProvinces();
    filteredProvinces = provinces;
    setState(() {});
  }

  Future<void> loadCarImage() async {
    final data = await DefaultAssetBundle.of(context).load('assets/car.jpg');
    final list = Uint8List.view(data.buffer);
    final codec = await ui.instantiateImageCodec(list);
    final frame = await codec.getNextFrame();
    carImage = frame.image;
    setState(() => isImageLoaded = true);
  }

  Widget buildSpiralLine() {
    if (!isImageLoaded) return const SizedBox(height: 100);
    return AnimatedBuilder(
      animation: _spiralController,
      builder: (context, child) {
        return CustomPaint(
          painter: SpiralLinePainter(_spiralController.value, carImage: carImage),
          size: const Size(double.infinity, 100),
        );
      },
    );
  }

  @override
  void dispose() {
    _spiralController.dispose();
    _entryController.dispose();
    searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
    bottomNavigationBar: BottomNavigationBar(
  selectedItemColor: const Color(0xFF2E7D32),
  unselectedItemColor: Colors.grey,
  type: BottomNavigationBarType.fixed,
    currentIndex: 0,
    onTap: (index) {
      if (index == 3) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MyAccountPage()),
        );
      }
    },
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: "الرئيسية"),
      BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "التنبيهات"),
      BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "المفضلة"),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: "الملف الشخصي"),
    ],
),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE8F5E9), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.green, width: 3),
                image: const DecorationImage(
                  image: AssetImage('assets/takkeh_logo.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // فيلد المحافظة مع البحث داخل نفس الواجهة
         Column(
  children: [
    Row(
      children: [
             const SizedBox(width: 8),

        // أيقونة الخريطة بجانب الفيلد
        IconButton(
          icon: const Icon(Icons.location_on, color: Colors.green, size: 30),
          onPressed: () {
            // هنا منطق تحديد الموقع
          },
        ),
        // حقل البحث
        Expanded(
          child: TextField(
            controller: searchCtrl,
            decoration: InputDecoration(
              hintText: "اختر أو ابحث عن المحافظة",
              labelText: "المحافظة",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onTap: () => setState(() => showList = true),
          ),
        ),
       
        // السهم لفتح/إغلاق القائمة
        GestureDetector(
          onTap: () => setState(() => showList = !showList),
          child: Icon(
            showList ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            size: 30,
            color: Colors.black,
          ),
        ),

      ],
    ),

    if (showList)
      SizedBox(
        height: 150,
        child: ListView.builder(
          itemCount: filteredProvinces.length,
          itemBuilder: (context, index) {
            final prov = filteredProvinces[index];
            return Card(
              elevation: 1,
              child: ListTile(
                title: Text(prov),
                onTap: () async {
                  setState(() {
                    selectedProvince = prov;
                    showList = false;
                    searchCtrl.text = prov;
                  });

                  final cities = await controller.getCities(prov);
                  if (cities.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CitiesPage(province: prov, cities: cities),
                      ),
                    );
                  }
                },
              ),
            );
          },
        ),
      ),
  ],
),


            const SizedBox(height: 40),
            FadeTransition(
              opacity: _fadeAnimation,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SlideTransition(
                    position: _slideAnimationFirst,
                    child: Column(
                      children: const [
                        Icon(Icons.location_pin, color: Color(0xFF2E7D32), size: 40),
                        SizedBox(height: 10),
                        Text("موقعك الحالي", style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: buildSpiralLine(),
                    ),
                  ),
                  SlideTransition(
                    position: _slideAnimationSecond,
                    child: Column(
                      children: const [
                        SizedBox(height: 60),
                        Icon(Icons.location_pin, color: Color(0xFF2E7D32), size: 40),
                        Text(" المدينة المتجه إليها", style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 60),
            const Text(
              "اختر مدينة من القائمة أعلاه لعرض الحواجز والطرقات.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// SpiralLinePainter كما هو
class SpiralLinePainter extends CustomPainter {
  final double progress;
  final ui.Image carImage;
  SpiralLinePainter(this.progress, {required this.carImage});

  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = const Color(0xFF2E7D32)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final amplitude = 15.0;
    final wavelength = 60.0;
    double startX = 0;
    double baseY = size.height / 2;
    final slope = 0.2;

    path.moveTo(startX, baseY);
    while (startX < size.width) {
      double y = baseY +
          slope * startX +
          amplitude * sin((startX / wavelength + progress * 2 * pi));
      path.lineTo(startX, y);
      startX += 2;
    }
    canvas.drawPath(path, paintLine);

    int numCars = 3;
    double spacing = size.width / numCars;

    for (int i = 0; i < numCars; i++) {
      double carX = (progress * size.width + i * spacing) % size.width;
      double carY = baseY +
          slope * carX +
          amplitude * sin((carX / wavelength + progress * 2 * pi));

      final rect = Rect.fromCenter(center: Offset(carX, carY), width: 40, height: 45);
      paintImage(canvas: canvas, rect: rect, image: carImage, fit: BoxFit.contain);
    }
  }

  @override
  bool shouldRepaint(covariant SpiralLinePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
