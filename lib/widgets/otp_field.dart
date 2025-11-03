import 'package:flutter/material.dart';

class OTPField extends StatelessWidget {
  final bool enabled;
  final List<TextEditingController> controllers;

  const OTPField({
    super.key,
    required this.enabled,
    required this.controllers,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.6,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(6, (index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            width: 42,
            height: 55,
            child: TextField(
              controller: controllers[index],
              enabled: enabled,
              textAlign: TextAlign.center,
              maxLength: 1,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF178C45),
              ),
              decoration: InputDecoration(
                counterText: "",
                filled: true,
                fillColor: Colors.green.shade50,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(width: 2, color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(width: 2, color: Color(0xFF178C45)),
                ),
              ),
              onChanged: (value) {
                // الانتقال للخانة التالية
                if (value.isNotEmpty && index < controllers.length - 1) {
                  FocusScope.of(context).nextFocus();
                }
                // الرجوع للخانة السابقة عند الحذف
                else if (value.isEmpty && index > 0) {
                  FocusScope.of(context).previousFocus();
                }
              },
            ),
          );
        }),
      ),
    );
  }
}
