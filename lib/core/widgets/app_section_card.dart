import 'package:flutter/material.dart';
import 'package:lego_rental_frontend/core/theme/app_colors.dart';

class AppSectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const AppSectionCard({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.text,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}