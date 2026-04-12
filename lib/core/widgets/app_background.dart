import 'package:flutter/material.dart';
import 'package:lego_rental_frontend/core/theme/app_colors.dart';
import 'package:lego_rental_frontend/core/theme/app_radius.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({
    super.key,
    required this.title,
    this.onBack,
    this.onHome,
    required this.child,
  });

  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onHome;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.brandHeader,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  if (onBack != null)
                    IconButton(
                      onPressed: onBack,
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 22,
                      ),
                      visualDensity: VisualDensity.compact,
                    )
                  else
                    const SizedBox(width: 44),

                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),

                  if (onHome != null)
                    IconButton(
                      onPressed: onHome,
                      icon: const Icon(
                        Icons.home,
                        color: Colors.white,
                        size: 22,
                      ),
                      visualDensity: VisualDensity.compact,
                    )
                  else
                    const SizedBox(width: 44),
                ],
              ),
            ),

            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.xl),
                    topRight: Radius.circular(AppRadius.xl),
                  ),
                ),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}