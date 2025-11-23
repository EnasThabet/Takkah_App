// views/my_account_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:takkeh/controllers/auth_controller.dart';

class MyAccountPage extends StatefulWidget {
  const MyAccountPage({super.key});

  @override
  State<MyAccountPage> createState() => _MyAccountPageState();
}

class _MyAccountPageState extends State<MyAccountPage> {
  bool _isEdited = false;
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    // load profile once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthController>(context, listen: false).loadUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Provider.of<AuthController>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9), // soft green
      appBar: AppBar(
        backgroundColor: const Color(0xFFE8F5E9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.green),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'حسابي',
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ctrl.loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                children: [
                  // avatar
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 46, color: Colors.green[700]),
                  ),
                  const SizedBox(height: 18),

                  // name
                  _field(
                    label: 'الاسم',
                    controller: ctrl.usernameCtrl,
                    onChanged: (_) => setState(() => _isEdited = true),
                  ),
                  const SizedBox(height: 14),

                  // phone
                  _field(
                    label: 'رقم الجوال',
                    controller: ctrl.phoneCtrl,
                    keyboard: TextInputType.phone,
                    onChanged: (_) => setState(() => _isEdited = true),
                  ),
                  const SizedBox(height: 14),

                  // password
                  _field(
                    label: 'كلمة المرور',
                    controller: ctrl.passCtrl,
                    obscure: !_showPassword,
                    suffix: IconButton(
                      icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _showPassword = !_showPassword),
                    ),
                    onChanged: (_) => setState(() => _isEdited = true),
                  ),
                  const SizedBox(height: 22),

                  // save button (only shown when edited)
                  if (_isEdited)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final ok = await ctrl.updateUserProfile(context);
                          if (ok) setState(() => _isEdited = false);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('حفظ التعديلات', style: TextStyle(fontSize: 16)),
                      ),
                    ),

                  const SizedBox(height: 12),

                  // logout button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () async {
                        await ctrl.supabase.auth.signOut();
                        Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.green),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('تسجيل الخروج', style: TextStyle(color: Colors.green)),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // delete account
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (dialogCtx) => AlertDialog(
                            title: const Text('حذف الحساب'),
                            content: const Text('هل أنت متأكدة من حذف الحساب نهائياً؟'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(dialogCtx, false), child: const Text('إلغاء')),
                              TextButton(onPressed: () => Navigator.pop(dialogCtx, true), child: const Text('حذف', style: TextStyle(color: Colors.red))),
                            ],
                          ),
                        );

                        if (confirmed == true) {
                          final ok = await ctrl.deleteAccount(context);
                          if (ok) {
                            Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('حذف الحساب', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    TextInputType keyboard = TextInputType.text,
    bool obscure = false,
    Widget? suffix,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboard,
          obscureText: obscure,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            suffixIcon: suffix,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.green),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.green, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
