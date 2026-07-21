import 'package:flutter/material.dart';
class ErrorText extends StatelessWidget {
  final String text;


  const ErrorText(this.text, {super.key});


  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.red,
          fontSize: 12,
        ),
      ),
    );
  }
}