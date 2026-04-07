import 'package:flutter/material.dart';
import 'package:lego_rental_frontend/core/models/lego_set_model.dart';
import 'package:lego_rental_frontend/core/services/api_service.dart';

class SetCard extends StatelessWidget {
  final LegoSetModel set;
  final VoidCallback? onTap;
  
  const SetCard({super.key, required this.set, this.onTap});

@override
Widget build(BuildContext context) {
  final imageUrl = set.imgUrl != null && set.imgUrl!.isNotEmpty
      ? '${ApiService.baseUrl}/proxy/image?url=${Uri.encodeComponent(set.imgUrl!)}'
      : null;

  return GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kép rész – fix magasság
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: SizedBox(
              height: 120, // kisebb kép, kevesebb overflow esély
              width: double.infinity,
              child: (imageUrl != null)
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF391713),
                            strokeWidth: 2,
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),
          ),

          // Szöveg rész – rugalmas, de nem kényszerített Expanded
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  set.title,
                  style: const TextStyle(
                    color: Color(0xFF391713),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '#${set.setNum}',
                  style: const TextStyle(
                    color: Color(0xFF848383),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
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
  );
}

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFFE8D5A3),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.extension, size: 36, color: Color(0xFF391713)),
            ...[
            const SizedBox(height: 4),
            Text(
              set.setNum!,
              style: const TextStyle(
                color: Color(0xFF391713),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          ],
        ),
      ),
    );
  }
}
