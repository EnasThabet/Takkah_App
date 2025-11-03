import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../widgets/otp_field.dart';

class SignUpView extends StatelessWidget {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthController(),
      child: const _SignUpContent(),
    );
  }
}

class _SignUpContent extends StatefulWidget {
  const _SignUpContent();

  @override
  State<_SignUpContent> createState() => _SignUpContentState();
}

class _SignUpContentState extends State<_SignUpContent> {
  bool showWelcome = false;

  void _createAccount(AuthController controller) {
    if (controller.validateAccount()) {
      setState(() => showWelcome = true);
      Timer(const Duration(seconds: 3), () {
        Navigator.pushReplacementNamed(context, '/login');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<AuthController>(context);

    return Scaffold(
      backgroundColor: Colors.green.shade50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  if (!showWelcome)
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.green),
                      onPressed: () {
                        if (controller.accountStep) {
                          controller.accountStep = false;
                        } else if (controller.otpStep) {
                          controller.otpStep = false;
                        } else {
                          Navigator.pop(context);
                        }
                        controller.notifyListeners();
                      },
                    ),
                  const Spacer(),
                  Image.asset('assets/takkeh_logo.png', width: 52, height: 52),
                ],
              ),
              const SizedBox(height: 20),

              Expanded(
                child: Center(
                  child: showWelcome
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.emoji_events,
                                color: Colors.green, size: 80),
                            SizedBox(height: 20),
                            Text("🎉 مرحباً بك في عائلة تكّة !",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                )),
                          ],
                        )
                      : SingleChildScrollView(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: _buildCurrentStep(context, controller),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep(BuildContext context, AuthController controller) {
    if (!controller.otpStep && !controller.accountStep) {
      return Column(
        key: const ValueKey('phone'),
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildPhoneField(controller),
          if (controller.phoneError != null)
            Padding(
              padding: const EdgeInsets.only(top: 5, right: 12),
              child: Text(
                controller.phoneError!,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
            ),
          const SizedBox(height: 20),
          _buildButton("إرسال كود التحقق", () => controller.sendOTP(context)),
        ],
      );
    }

    if (controller.otpStep && !controller.accountStep) {
      return Column(
        key: const ValueKey('otp'),
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text("أدخل الكود المرسل",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green)),
          const SizedBox(height: 20),
          OTPField(enabled: true, controllers: controller.otpControllers),
          if (controller.otpError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                controller.otpError!,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
            ),
          const SizedBox(height: 20),
          _buildButton("تأكيد الكود", () => controller.verifyOTP(context)),
        ],
      );
    }

    return Column(
      key: const ValueKey('account'),
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildField("اسم المستخدم", controller.usernameCtrl,
            error: controller.usernameError),
        const SizedBox(height: 15),
        _buildField("كلمة المرور", controller.passCtrl,
            obscure: true, error: controller.passError),
        const SizedBox(height: 15),
        _buildField("تأكيد كلمة المرور", controller.confirmCtrl,
            obscure: true, error: controller.confirmError),
        const SizedBox(height: 25),
        _buildButton("إنشاء الحساب", () => _createAccount(controller)),
      ],
    );
  }

  Widget _buildPhoneField(AuthController controller) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            borderRadius: BorderRadius.circular(25),
          ),
          child: const Text(
            "+972",
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: controller.phoneCtrl,
            keyboardType: TextInputType.number,
            maxLength: 10,
            decoration: InputDecoration(
              counterText: "",
              labelText: "رقم الجوال",
              errorText: controller.phoneError,
              labelStyle: const TextStyle(color: Colors.green),
              filled: true,
              fillColor: Colors.green.shade50,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildField(String label, TextEditingController controller,
      {bool obscure = false, String? error}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        labelText: label,
        errorText: error,
        labelStyle: const TextStyle(color: Colors.green),
        filled: true,
        fillColor: Colors.green.shade50,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
