import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends ChangeNotifier {
  // ===================== Controllers =====================
  final usernameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  final otpControllers = List.generate(6, (_) => TextEditingController());
    final supabase = Supabase.instance.client;


  // ===================== States =====================
  bool otpStep = false;
  bool accountStep = false;

  // ===================== Firebase Auth =====================
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId;
  ConfirmationResult? _confirmationResult; // خاص بالويب

  // ===================== Server URL =====================
  final String serverUrl = "http://192.168.0.111:3000";
  // final String serverUrl = "http://localhost:3000";

  // ===================== Dispose =====================
  @override
  void dispose() {
    usernameCtrl.dispose();
    phoneCtrl.dispose();
    passCtrl.dispose();
    confirmCtrl.dispose();
    for (var c in otpControllers) {
      c.dispose();
    }
    super.dispose();
  }

  // ===================== Firebase OTP =====================

  // 🔹 إرسال كود OTP
  Future<void> sendOTP(BuildContext context, String fullNumber) async {
    if (fullNumber.isEmpty) {
      _showMessage(context, "ادخلي رقم الجوال أولًا");
      return;
    }

    try {
      if (kIsWeb) {
        // 🔹 WEB flow
        //_showMessage(context, "جاري إرسال الكود (web) — سيظهر reCAPTCHA الآن");
        _confirmationResult = await _auth.signInWithPhoneNumber(fullNumber);
        debugPrint('✅ ConfirmationResult created for $fullNumber');
        otpStep = true;
        accountStep = false;
        notifyListeners();
      } else {
        // 🔹 MOBILE flow
        await _auth.verifyPhoneNumber(
          phoneNumber: fullNumber,
          timeout: const Duration(seconds: 60),
          verificationCompleted: (PhoneAuthCredential credential) async {
            debugPrint('verificationCompleted (auto): $credential');
            await _auth.signInWithCredential(credential);
            _showMessage(context, "تم التحقق تلقائيًا ✅");
            otpStep = false;
            accountStep = true;
            notifyListeners();
          },
          verificationFailed: (FirebaseAuthException e) {
            debugPrint('verificationFailed: ${e.code} - ${e.message}');
            _showMessage(context, "فشل التحقق: ${e.message}");
          },
          codeSent: (String verificationId, int? resendToken) {
            debugPrint('codeSent -> verificationId: $verificationId');
            _verificationId = verificationId;
            otpStep = true;
            accountStep = false;
            notifyListeners();
            _showMessage(context, "تم إرسال كود التحقق");
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            debugPrint('codeAutoRetrievalTimeout -> $verificationId');
            _verificationId = verificationId;
          },
        );
      }
    } catch (e, st) {
      debugPrint('sendOTP error: $e\n$st');
      _showMessage(context, "خطأ أثناء الإرسال: $e");
    }
  }

  // 🔹 التحقق من الكود
  Future<void> verifyOTP(BuildContext context) async {
    final enteredCode = otpControllers.map((c) => c.text).join();
    if (enteredCode.isEmpty) {
      _showMessage(context, "أدخلي الكود أولًا");
      return;
    }

    try {
      if (kIsWeb) {
        // WEB: use confirmationResult.confirm(code)
        if (_confirmationResult == null) {
          _showMessage(context, "لم يتم إرسال الكود بعد (web)");
          debugPrint('No confirmationResult available on web.');
          return;
        }
        final userCred = await _confirmationResult!.confirm(enteredCode);
        debugPrint('web signIn success user: ${userCred.user}');
        if (userCred.user != null) {
          _showMessage(context, "تم التحقق وتسجيل الدخول ✅");
          otpStep = false;
          accountStep = true;
          notifyListeners();
        } else {
          _showMessage(context, "فشل تسجيل الدخول (web)");
        }
      } else {
        // MOBILE: use PhoneAuthProvider credential with verificationId
        if (_verificationId == null) {
          _showMessage(context, "لم يتم استلام verificationId بعد");
          debugPrint('No verificationId available on mobile.');
          return;
        }
        final credential = PhoneAuthProvider.credential(
          verificationId: _verificationId!,
          smsCode: enteredCode,
        );
        final userCred = await _auth.signInWithCredential(credential);
        debugPrint('mobile signIn success user: ${userCred.user}');
        if (userCred.user != null) {
          _showMessage(context, " تم التحقق بنجاح ✅");
          otpStep = false;
          accountStep = true;
          notifyListeners();
        } else {
          _showMessage(context, "فشل تسجيل الدخول");
        }
      }
    } catch (e, st) {
      debugPrint('verifyOTP error: $e\n$st');
      _showMessage(context, "الكود غير صحيح أو انتهت صلاحيته");
    }
  }

  // ===================== Register User =====================
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

    final fullNumber = phone.startsWith('+') ? phone : '+970$phone';

    try {
      final response = await http.post(
        Uri.parse("$serverUrl/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "phone_number": fullNumber,
          "password_hash": password,
        }),
      );

      if (response.statusCode == 200) {
        _showMessage(context, "تم إنشاء الحساب بنجاح 🎉");
      } else {
        _showMessage(
          context,
          "خطأ من السيرفر: ${response.statusCode} ${response.body}",
        );
      }
    } catch (e) {
      _showMessage(context, "تعذر الاتصال بالسيرفر: $e");
    }
  }
   bool loading = false;

  /// load the current logged-in user's profile from 'users' table
  Future<void> loadUserProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    loading = true;
    notifyListeners();

    try {
      final res = await supabase
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (res != null) {
        final Map<String, dynamic> row = res as Map<String, dynamic>;
        usernameCtrl.text = row['username'] ?? '';
        phoneCtrl.text = row['phone_number'] ?? '';
        passCtrl.text = row['password_hash'] ?? '';
      }
    } catch (e) {
      debugPrint('loadUserProfile error: $e');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// update DB row for current user
  Future<bool> updateUserProfile(BuildContext context) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      _showMessage(context, "المستخدم غير مسجّل");
      return false;
    }

    final updateData = {
      'username': usernameCtrl.text.trim(),
      'phone_number': phoneCtrl.text.trim(),
      'password_hash': passCtrl.text.trim(),
    };

    try {
      final res = await supabase
          .from('users')
          .update(updateData)
          .eq('id', user.id);

      // supabase Dart client returns PostgrestResponse-like object; check error
      // If using older/newer SDK adjust as necessary:
      // if (res.error != null) { ... }
      _showMessage(context, "تم حفظ التعديلات بنجاح");
      return true;
    } catch (e) {
      debugPrint('updateUserProfile error: $e');
      _showMessage(context, "فشل حفظ التعديلات");
      return false;
    }
  }

  /// delete user record from 'users' then sign out (does not delete auth user)
  Future<bool> deleteAccount(BuildContext context) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      _showMessage(context, "لا يوجد مستخدم");
      return false;
    }

    try {
      await supabase.from('users').delete().eq('id', user.id);

      // sign out
      await supabase.auth.signOut();

      _showMessage(context, "تم حذف الحساب نهائيًا");
      return true;
    } catch (e) {
      debugPrint('deleteAccount error: $e');
      _showMessage(context, "فشل حذف الحساب");
      return false;
    }
  }

  void disposeControllers() {
    usernameCtrl.dispose();
    phoneCtrl.dispose();
    passCtrl.dispose();
  }


  // ===================== Login User =====================
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
        body: jsonEncode({"username": username, "password_hash": password}),
      );

      if (response.statusCode == 200) {
        _showMessage(context, "تم تسجيل الدخول بنجاح ✅");
      } else {
        final resp = response.body;
        _showMessage(context, "خطأ من السيرفر: ${response.statusCode} $resp");
      }
    } catch (e) {
      _showMessage(context, "تعذر الاتصال بالسيرفر: $e");
    }
  }

  // ===================== Snack Message =====================
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
}
