// models/user_model.dart
class UserModel {
  final String name;
  final String phone;
  final String password;
  final List<String> subscriptions;

  UserModel({
    required this.name,
    required this.phone,
    required this.password,
    required this.subscriptions,
  });

  factory UserModel.fromMap(Map<String, dynamic> m) {
    return UserModel(
      name: m['name'] ?? '',
      phone: m['phone'] ?? '',
      password: m['password'] ?? '',
      subscriptions: (m['subscriptions'] is List)
          ? List<String>.from(m['subscriptions'])
          : <String>[],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'password': password,
      'subscriptions': subscriptions,
    };
  }

  UserModel copyWith({
    String? name,
    String? phone,
    String? password,
    List<String>? subscriptions,
  }) {
    return UserModel(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      subscriptions: subscriptions ?? this.subscriptions,
    );
  }
}
