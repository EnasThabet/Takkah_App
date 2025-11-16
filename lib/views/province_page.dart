import 'package:flutter/material.dart';
import '../controllers/province_controller.dart';
import 'cities_page.dart';

class ProvincePage extends StatefulWidget {
  const ProvincePage({super.key});

  @override
  State<ProvincePage> createState() => _ProvincePageState();
}

class _ProvincePageState extends State<ProvincePage>
    with SingleTickerProviderStateMixin {
  final ProvinceController controller = ProvinceController();

  List<String> provinces = [];
  List<String> filteredProvinces = [];
  bool showList = false;

  // 🔥 Animation Controller for shake effect
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  final TextEditingController searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProvinces();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _shakeAnimation =
        Tween<double>(begin: 0, end: 16).chain(CurveTween(curve: Curves.elasticIn)).animate(_shakeController);

    searchCtrl.addListener(() {
      filterProvinces(searchCtrl.text);
    });
  }

  void filterProvinces(String query) {
    final filtered = provinces
        .where((p) => p.toLowerCase().contains(query.toLowerCase()))
        .toList();
    setState(() => filteredProvinces = filtered);
  }

  Future<void> loadProvinces() async {
    provinces = await controller.getProvinces();
    filteredProvinces = provinces;
    setState(() {});
  }

  void triggerShake() {
    _shakeController.forward(from: 0);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    searchCtrl.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text("اختر المحافظة"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _shakeController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_shakeAnimation.value, 0),
                  child: child,
                );
              },
              child: Row(
                children: [
                  const Icon(Icons.map, color: Colors.green, size: 30),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: searchCtrl,
                      onTap: () {
                        setState(() => showList = true);
                        triggerShake();
                      },
                      decoration: InputDecoration(
                        hintText: "ابحث أو اختر المحافظة...",
                        labelText: "المحافظة",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() => showList = !showList);
                            triggerShake();
                          },
                          child: Icon(
                            showList
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            size: 30,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            if (showList)
              Expanded(
                child: ListView.builder(
                  itemCount: filteredProvinces.length,
                  itemBuilder: (context, index) {
                    final province = filteredProvinces[index];
                    return Card(
                      elevation: 1,
                      child: ListTile(
                        title: Text(province),
                        onTap: () async {
                          final cities = await controller.getCities(province);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CitiesPage(
                                province: province,
                                cities: cities,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
