import 'package:flutter/material.dart';
import 'package:lego_rental_frontend/core/models/lego_set_model.dart';
import 'package:lego_rental_frontend/core/services/api_service.dart';

class LegoSetCard extends StatelessWidget {
  final LegoSetModel set;
  const LegoSetCard({super.key, required this.set, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {

    final imageUrl = set.imgUrl != null
        ? '${ApiService.baseUrl}/proxy/image?url=${Uri.encodeComponent(set.imgUrl!)}'
        : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 235, 235, 235),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Bal oldali kép placeholder
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 100,
                height: 100,
                child: Builder(
                  builder: (context) {
                    final imageUrl =
                        set.imgUrl != null && set.imgUrl!.isNotEmpty
                        ? '${ApiService.baseUrl}/proxy/image?url=${Uri.encodeComponent(set.imgUrl!)}'
                        : null;
                    return (imageUrl != null)
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.extension,
                              size: 36,
                              color: Color(0xFF391713),
                            ),
                          )
                        : const Icon(
                            Icons.extension,
                            size: 36,
                            color: Color(0xFF391713),
                          );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Jobb oldali szövegek
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    set.title,
                    style: const TextStyle(
                      color: Color(0xFF391713),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    set.location!,
                    style: const TextStyle(
                      color: Color(0xFF252525),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Set #: ${set.setNum}',
                    style: const TextStyle(
                      color: Color(0xFF391713),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: const [
                      Text(
                        'Rating: 4.8',
                        style: TextStyle(
                          color: Color(0xFF848383),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
