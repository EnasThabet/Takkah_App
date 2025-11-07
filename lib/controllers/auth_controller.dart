import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AuthController extends ChangeNotifier {
  // 🔗 Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 📱 Controllers
  final usernameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController(text: '05');
  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  final otpControllers = List.generate(6, (_) => TextEditingController());

  // 🧩 متغيرات الحالة
  String? verificationId;
  bool otpStep = false;
  bool accountStep = false;

  // ⚠️ رسائل الخطأ
  String? usernameError;
  String? phoneError;
  String? passError;
  String? confirmError;
  String? otpError;

  // 🧹 تهيئة للمراقبة التفاعلية (حتى تختفي الأخطاء عند الكتابة)
  AuthController() {
    usernameCtrl.addListener(_clearUsernameError);
    phoneCtrl.addListener(_clearPhoneError);
    passCtrl.addListener(_clearPassError);
    confirmCtrl.addListener(_clearConfirmError);
    for (var c in otpControllers) {
      c.addListener(_clearOtpError);
    }
  }

  void dispose() {
    usernameCtrl.dispose();
    phoneCtrl.dispose();
    passCtrl.dispose();
    confirmCtrl.dispose();
    for (var c in otpControllers) c.dispose();
    super.dispose();
  }

  // 🧼 مسح الأخطاء أثناء الكتابة
  void _clearUsernameError() {
    if (usernameError != null && usernameCtrl.text.isNotEmpty) {
      usernameError = null;
      notifyListeners();
    }
  }

  void _clearPhoneError() {
    if (phoneError != null && phoneCtrl.text.startsWith("05") && phoneCtrl.text.length == 10) {
      phoneError = null;
      notifyListeners();
    }
  }

  void _clearPassError() {
    if (passError != null && passCtrl.text.isNotEmpty) {
      passError = null;
      notifyListeners();
    }
  }

  void _clearConfirmError() {
    if (confirmError != null &&
        confirmCtrl.text.isNotEmpty &&
        confirmCtrl.text == passCtrl.text) {
      confirmError = null;
      notifyListeners();
    }
  }

  void _clearOtpError() {
    if (otpError != null && otpControllers.any((c) => c.text.isNotEmpty)) {
      otpError = null;
      notifyListeners();
    }
  }

  // ✅ تحقق من رقم الهاتف
  bool validatePhone() {
    final phone = phoneCtrl.text.trim();

    if (!phone.startsWith('05')) {
      phoneError = "يجب أن يبدأ رقم الجوال بـ 05";
      notifyListeners();
      return false;
    }

    if (!RegExp(r'^05\d{8}$').hasMatch(phone)) {
      phoneError = "رقم الجوال يجب أن يتكون من 10 أرقام";
      notifyListeners();
      return false;
    }

    phoneError = null;
    notifyListeners();
    return true;
  }

  // ✅ تحقق من الحقول الأساسية
  bool validateAccount() {
    usernameError = null;
    passError = null;
    confirmError = null;

    if (usernameCtrl.text.isEmpty) {
      usernameError = "الاسم مطلوب";
    }

    if (passCtrl.text.isEmpty) {
      passError = "كلمة المرور مطلوبة";
    } else if (passCtrl.text.length < 6) {
      passError = "كلمة المرور قصيرة جدًا";
    }

    if (confirmCtrl.text != passCtrl.text) {
      confirmError = "كلمة المرور غير متطابقة";
    }

    notifyListeners();

    return usernameError == null &&
        phoneError == null &&
        passError == null &&
        confirmError == null;
  }

  // 📩 إرسال OTP
  Future<void> sendOTP(BuildContext context) async {
    if (!validatePhone()) return;

    final phone = "+972${phoneCtrl.text.substring(1)}";

    if (kIsWeb) {
      verificationId = "web-test";
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Web test OTP: 123456")),
      );
      otpStep = true;
      notifyListeners();
      return;
    }

    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (e) {
        phoneError = "فشل التحقق: ${e.message}";
        notifyListeners();
      },
      codeSent: (verId, _) {
        verificationId = verId;
        otpStep = true;
        notifyListeners();
      },
      codeAutoRetrievalTimeout: (verId) {
        verificationId = verId;
      },
    );
  }

  // 🔐 تحقق من كود OTP
  Future<bool> verifyOTP(BuildContext context) async {
    String otp = otpControllers.map((c) => c.text).join();
    if (otp.isEmpty || otp.length < 6) {
      otpError = "الرمز غير مكتمل";
      notifyListeners();
      return false;
    }

    if (kIsWeb && otp == "123456") {
      accountStep = true;
      otpStep = false;
      notifyListeners();
      return true;
    }

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId!,
        smsCode: otp,
      );

      await _auth.signInWithCredential(credential);
      accountStep = true;
      otpStep = false;
      notifyListeners();
      return true;
    } catch (e) {
      otpError = "رمز التحقق غير صحيح";
      notifyListeners();
      return false;
    }
  }

  // 🧠 تسجيل الدخول تجريبي
  bool login(String username, String password) {
    if ((username == "takkeh" || username == "0590000000") && password == "12345") {
      debugPrint("✅ تسجيل دخول ناجح");
      return true;
    }
    debugPrint("❌ فشل تسجيل الدخول");
    return false;
  }
}
