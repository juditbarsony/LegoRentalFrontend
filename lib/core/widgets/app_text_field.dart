import 'package:flutter/material.dart';
import 'package:lego_rental_frontend/core/theme/app_colors.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final String? label;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final VoidCallback? onTap;
  final bool readOnly;
  final String? Function(String?)? validator;
  final int maxLines;

  const AppTextField({
    super.key,
    this.controller,
    required this.hintText,
    this.label,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.onTap,
    this.readOnly = false,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final field = TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onTap: onTap,
      readOnly: readOnly,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: suffixIcon,
      ),
    );

    if (label == null) return field;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label!,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.text,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
        ),
        const SizedBox(height: 6),
        field,
      ],
    );
  }
}
