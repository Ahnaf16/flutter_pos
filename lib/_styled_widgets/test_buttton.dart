import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class NonSelectableShadButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const NonSelectableShadButton({
    super.key,
    required this.onPressed,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return ShadButton(
      onPressed: onPressed,
      child: SelectionContainer.disabled(
        child: Text(
          text,
          style: const TextStyle(
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}
