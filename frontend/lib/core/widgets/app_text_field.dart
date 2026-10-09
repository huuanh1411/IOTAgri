// lib/core/widgets/app_text_field.dart
import 'package:flutter/material.dart';
import '../theme/theme.dart'; // UIConsts, AppText

/// A reusable text field with optional label, error text, and password toggle.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.controller,
    this.label,
    this.errorText,
    this.hintText,
    this.isPassword = false,
    this.onChanged,
  });

  final TextEditingController controller;
  final String? label;
  final String? errorText;
  final String? hintText;
  final bool isPassword;
  final ValueChanged<String>? onChanged;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _obscure = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(widget.label!, style: AppText.body),
          ),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscure,
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            hintText: widget.hintText,
            errorText: widget.errorText,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
