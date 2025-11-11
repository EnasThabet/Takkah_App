import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final AuthController _controller = AuthController();
  bool _isLoading = false;
  bool _obscure = true;
  String? _error;

 Future<void> _login() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() {
    _isLoading = true;
    _error = null;
  });

  try {
    // استدعاء دالة loginUser من AuthController
    await _controller.loginUser(context);
  } catch (e) {
    setState(() {
      _error = "حدث خطأ غير متوقع: $e";
    });
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade700, Colors.green.shade400],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/takkeh_logo.png',
                          width: 52,
                          height: 52,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Takkeh',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 6,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _controller.usernameCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'اسم المستخدم أو رقم الهاتف',
                                  prefixIcon: Icon(Icons.person),
                                ),
                                validator:
                                    (v) =>
                                        v!.isEmpty
                                            ? 'الرجاء إدخال اسم المستخدم'
                                            : null,
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _controller.passCtrl,
                                obscureText: _obscure,
                                decoration: InputDecoration(
                                  labelText: 'كلمة المرور',
                                  prefixIcon: const Icon(Icons.lock),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscure
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed:
                                        () => setState(
                                          () => _obscure = !_obscure,
                                        ),
                                  ),
                                ),
                                validator:
                                    (v) =>
                                        v!.isEmpty
                                            ? 'الرجاء إدخال كلمة المرور'
                                            : null,
                              ),
                              const SizedBox(height: 8),
                              if (_error != null)
                                Text(
                                  _error!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child:
                                    _isLoading
                                        ? const CircularProgressIndicator()
                                        : ElevatedButton(
                                          onPressed: _login,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.green.shade700,
                                          ),
                                          child: const Text("تسجيل الدخول"),
                                        ),
                              ),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed:
                                    () => Navigator.pushNamed(
                                      context,
                                      '/signupscreen',
                                    ),
                                child: const Text("إنشاء حساب جديد"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
