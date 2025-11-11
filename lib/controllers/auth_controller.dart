import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthController extends ChangeNotifier {
  final usernameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  final otpControllers = List.generate(6, (_) => TextEditingController());

  bool otpStep = false;
  bool accountStep = false;
  int? generatedCode;

  final String serverUrl = "http://192.168.0.112:3000";
  
  //final String serverUrl = "http://localhost:3000";


  @override
  void dispose() {
    usernameCtrl.dispose();
    phoneCtrl.dispose();
    passCtrl.dispose();
    confirmCtrl.dispose();
    for (var c in otpControllers) c.dispose();
    super.dispose();
  }

  int _generateCode() => 100000 + Random().nextInt(900000);

  // sendOTP now expects normalized full number (like +9705986...)
  Future<void> sendOTP(BuildContext context, String fullNumber) async {
    if (fullNumber.isEmpty) {
      _showMessage(context, "أدخل رقم الجوال أولًا");
      return;
    }

    generatedCode = _generateCode();
    otpStep = true;
    accountStep = false;
    notifyListeners();

    print('🔢 OTP sent (debug): $generatedCode to $fullNumber');
    _showMessage(context, "تم إرسال كود التحقق إلى رقمك");
  }

  Future<void> verifyOTP(BuildContext context) async {
    final enteredCode = otpControllers.map((c) => c.text).join();

    if (generatedCode == null) {
      _showMessage(context, "الرجاء طلب الكود أولًا");
      return;
    }

    if (enteredCode == generatedCode.toString()) {
      _showMessage(context, "تم التحقق بنجاح");
      otpStep = false;
      accountStep = true;
      generatedCode = null;
      notifyListeners();
    } else {
      _showMessage(context, "الكود غير صحيح");
    }
  }

 Future<void> registerUser(BuildContext context) async {
  final username = usernameCtrl.text.trim();
  final phone = phoneCtrl.text.trim();
  final password = passCtrl.text.trim();
  final confirm = confirmCtrl.text.trim();

  if (username.isEmpty || phone.isEmpty || password.isEmpty) {
    _showMessage(context, "املأ جميع الحقول");
    return;
  }
  if (password != confirm) {
    _showMessage(context, "كلمة المرور غير متطابقة");
    return;
  }

  // 🔹 تأكدي من الشكل النهائي للرقم
  final fullNumber = phone.startsWith('+') ? phone : '+970$phone';

  try {
    final response = await http.post(
      Uri.parse("$serverUrl/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "phone_number": fullNumber, // صيغة +970xxxxxxx
        "password_hash": password,
      }),
    );

    if (response.statusCode == 200) {
      _showMessage(context, "تم إنشاء الحساب بنجاح 🎉");
    } else {
      _showMessage(context, "خطأ من السيرفر: ${response.statusCode} ${response.body}");
    }
  } catch (e) {
    _showMessage(context, "تعذر الاتصال بالسيرفر: $e");
  }
}


  void _showMessage(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(child: Text(msg, textAlign: TextAlign.center)),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  
Future<void> loginUser(BuildContext context) async {
  final username = usernameCtrl.text.trim();
  final password = passCtrl.text.trim();

  if (username.isEmpty || password.isEmpty) {
    _showMessage(context, "املأ جميع الحقول");
    return;
  }

  try {
    final response = await http.post(
      Uri.parse("$serverUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "password_hash": password, // نفس الحقل في السيرفر
      }),
    );

    if (response.statusCode == 200) {
      _showMessage(context, "تم تسجيل الدخول بنجاح ✅");
      // هنا يمكنك حفظ بيانات الجلسة إذا أردت (token, user_id ...)
    } else {
      final resp = response.body;
      _showMessage(context, "خطأ من السيرفر: ${response.statusCode} $resp");
    }
  } catch (e) {
    _showMessage(context, "تعذر الاتصال بالسيرفر: $e");
  }
}

}
