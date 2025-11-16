class Province {
  final String provinceName;
  final String cityName;

  Province({required this.provinceName, required this.cityName});

  factory Province.fromMap(Map<String, dynamic> map) {
    return Province(
      provinceName: map['province_name'],
      cityName: map['city_name'],
    );
  }
}