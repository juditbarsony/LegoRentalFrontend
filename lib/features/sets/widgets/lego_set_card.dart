import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lego_rental_frontend/core/models/lego_set_model.dart';
import 'package:lego_rental_frontend/core/services/api_service.dart';
import 'package:lego_rental_frontend/core/theme/app_colors.dart';
import 'package:lego_rental_frontend/core/theme/app_radius.dart';
import 'package:lego_rental_frontend/core/theme/app_spacing.dart';
import 'package:lego_rental_frontend/core/theme/app_text_styles.dart';

class LegoSetCard extends StatelessWidget {
  final LegoSetModel set;
  final VoidCallback? onTap;

  const LegoSetCard({
    super.key,
    required this.set,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = set.imgUrl != null && set.imgUrl!.isNotEmpty
        ? '${ApiService.baseUrl}/proxy/image?url=${Uri.encodeComponent(set.imgUrl!)}'
        : null;

    if (kDebugMode) {
      debugPrint('CARD IMG URL: ${set.imgUrl}');
      debugPrint('FULL URL: $imageUrl');
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: SizedBox(
                    width: 108,
                    height: 108,
                    child: imageUrl != null
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.text,
                                  strokeWidth: 2,
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) => _buildPlaceholder(),
                          )
                        : _buildPlaceholder(),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        set.title,
                        style: AppTextStyles.cardTitle.copyWith(height: 1.2),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '#${set.setNum}',
                        style: AppTextStyles.meta.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        set.location,
                        style: AppTextStyles.body.copyWith(
                          fontSize: 13,
                          color: AppColors.text,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFFE8D5A3),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.extension,
              size: 32,
              color: AppColors.text,
            ),
            const SizedBox(height: 4),
            Text(
              set.setNum ?? '',
              style: AppTextStyles.meta.copyWith(
                color: AppColors.text,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}