import 'package:supabase_flutter/supabase_flutter.dart';

class ProvinceController {
  final supabase = Supabase.instance.client;

  // جلب المحافظات بدون تكرار
  Future<List<String>> getProvinces() async {
    final response = await supabase.from('cities').select('province_name').order('province_name');

    return (response as List)
        .map((e) => e['province_name'].toString())
        .toSet() // إزالة التكرار
        .toList();
  }

  // جلب المدن حسب المحافظة
  Future<List<String>> getCities(String province) async {
    final response = await supabase
        .from('cities')
        .select('city_name')
        .eq('province_name', province)
        .order('city_name');

    return (response as List).map((e) => e['city_name'].toString()).toList();
  }
}