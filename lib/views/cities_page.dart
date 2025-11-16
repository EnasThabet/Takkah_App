import 'package:flutter/material.dart';

class CitiesPage extends StatelessWidget {
  final String province;
  final List<String> cities;

  const CitiesPage({super.key, required this.province, required this.cities});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('المدن في $province', style: const TextStyle(fontWeight: FontWeight.bold,color: Color.fromARGB(255, 46, 159, 110)),),
        backgroundColor: const Color.fromARGB(255, 89, 188, 227),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: cities.length,
          itemBuilder: (context, index) {
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(
                  cities[index],
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                onTap: () {
                  // هنا ممكن تحددي فعل عند الضغط على المدينة
                  print('اخترت: ${cities[index]}');
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
