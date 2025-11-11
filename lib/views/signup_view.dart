import 'dart:ui';
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
  String selectedCountryCode = '+970'; // default
  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<AuthController>(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFA8E6CF), Color(0xFFF0FFF4)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(color: Colors.white.withOpacity(0.1)),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Column(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.green, width: 3),
                            image: const DecorationImage(
                              image: AssetImage('assets/takkeh_logo.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "إنشاء حساب تكّة",
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: 24,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: _buildCurrentStep(context, controller),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: RichText(
                        text: TextSpan(
                          text: "لديك حساب بالفعل؟ ",
                          style: const TextStyle(
                              color: Colors.black87, fontSize: 15),
                          children: [
                            TextSpan(
                              text: "تسجيل الدخول",
                              style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
          const SizedBox(height: 20),
          _buildButton("إرسال كود التحقق", () {
            String phoneInput = controller.phoneCtrl.text.trim();

            // قبول 10 أرقام تبدأ بـ0 (مثال 059...) أو 9 أرقام تبدأ بـ5 (598...)
            if (!RegExp(r'^(0?5\d{8})$').hasMatch(phoneInput)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('الرجاء إدخال رقم جوال صالح (مثال: 0591234567 أو 591234567)'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            // تطبيع الرقم: إذا بدأ بـ0 شيلها
            String normalizedLocal = phoneInput.startsWith('0')
                ? phoneInput.substring(1)
                : phoneInput;

            // fullNumber جاهز كـ +970598...
            final fullNumber = "$selectedCountryCode$normalizedLocal";

            // نخزّن الشكل النهائي في phoneCtrl لو بدنا نرسله للسيرفر لاحقاً
            controller.phoneCtrl.text = normalizedLocal;

            controller.sendOTP(context, fullNumber);
          }),
        ],
      );
    }

    if (controller.otpStep && !controller.accountStep) {
      return Column(
        key: const ValueKey('otp'),
        children: [
          const Text(
            "أدخل الكود المرسل إلى رقمك",
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
          ),
          const SizedBox(height: 20),
          Directionality(
            textDirection: TextDirection.ltr,
            child: OTPField(
              enabled: true,
              controllers: controller.otpControllers,
            ),
          ),
          const SizedBox(height: 20),
          _buildButton("تأكيد الكود", () async {
            await controller.verifyOTP(context);
          }),
        ],
      );
    }

    if (controller.accountStep) {
      return Column(
        key: const ValueKey('account'),
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildField("اسم المستخدم", controller.usernameCtrl),
          const SizedBox(height: 15),
          _buildField("كلمة المرور", controller.passCtrl, obscure: true),
          const SizedBox(height: 15),
          _buildField("تأكيد كلمة المرور", controller.confirmCtrl, obscure: true),
          const SizedBox(height: 25),
          _buildButton("إنشاء الحساب", () async {
            // phoneCtrl الآن يحتوي على local normalized (مثال 59xxxxxxx) — إذا تريدين إرسال مع المقدمة:
            final phoneToSend = "$selectedCountryCode${controller.phoneCtrl.text.trim()}";
            controller.phoneCtrl.text = phoneToSend; // استبدل الحقل قبل الإرسال
            await controller.registerUser(context);
          }),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildPhoneField(AuthController controller) => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 12, bottom: 8),
            child: Text("رقم الجوال",
                style: TextStyle(
                    color: Colors.green,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
          ),
          Row(
            children: [
              Container(
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    bottomLeft: Radius.circular(25),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCountryCode,
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.green),
                    items: const [
                      DropdownMenuItem(
                        value: '+970',
                        child: Text('🇵🇸 +970', style: TextStyle(color: Colors.green)),
                      ),
                      DropdownMenuItem(
                        value: '+972',
                        child: Text('🇮🇱 +972', style: TextStyle(color: Colors.green)),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedCountryCode = value!;
                      });
                    },
                  ),
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: controller.phoneCtrl,
                  keyboardType: TextInputType.phone,
                  textDirection: TextDirection.ltr,
                  decoration: InputDecoration(
                    hintText: "0591234567 أو 591234567",
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.6),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(25),
                        bottomRight: Radius.circular(25),
                      ),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );

  Widget _buildField(String label, TextEditingController ctrl,
          {bool obscure = false}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 12, bottom: 8),
            child: Text(label,
                style: const TextStyle(color: Colors.green, fontSize: 14)),
          ),
          TextField(
            controller: ctrl,
            obscureText: obscure,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      );

  Widget _buildButton(String text, VoidCallback onPressed) => SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          ),
          child: Text(text,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      );
}
