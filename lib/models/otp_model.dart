import 'package:flutter/material.dart';

class OTP extends StatelessWidget {
  final bool enabled;
  final List<TextEditingController> controllers;

  const OTP({super.key, required this.enabled, required this.controllers});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 45,
          child: TextField(
            controller: controllers[index],
            enabled: enabled,
            textAlign: TextAlign.center,
            maxLength: 1,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              counterText: '',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              if (value.length == 1 && index < controllers.length - 1) {
                FocusScope.of(context).nextFocus();
              } else if (value.isEmpty && index > 0) {
                FocusScope.of(context).previousFocus();
              }
            },
          ),
        );
      }),
    );
  }
}
