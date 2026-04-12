import 'package:flutter/material.dart';
import 'package:lego_rental_frontend/core/theme/app_colors.dart';

class AppDropdown<T> extends StatelessWidget {
  final String? label;
  final String hintText;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;
  final bool enabled;

  const AppDropdown({
    super.key,
    this.label,
    required this.hintText,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final field = DropdownButtonFormField<T>(
      value: value,
      isDense: true,
      isExpanded: true,
      validator: validator,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.text,
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
      ),
      hint: Text(
        hintText,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
      ),
      borderRadius: BorderRadius.circular(14),
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        size: 20,
        color: AppColors.textMuted,
      ),
      dropdownColor: Colors.white,
      items: items,
      onChanged: enabled ? onChanged : null,
    );

    if (label == null) return field;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label!,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.text,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 6),
        field,
      ],
    );
  }
}