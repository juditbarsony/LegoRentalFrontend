import 'package:flutter/material.dart';

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
      color: const Color(0xFFF5CB58), // sárga háttér
      child: SafeArea(
        child: Column(
          children: [
            // Felső sárga header sor
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  // Bal oldal: vissza gomb
                  if (onBack != null)
                    IconButton(
                      onPressed: onBack,
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    )
                  else
                    const SizedBox(width: 48),

                  // Középen: cím
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // Jobb oldal: home gomb
                  if (onHome != null)
                    IconButton(
                      onPressed: onHome,
                      icon: const Icon(Icons.home, color: Colors.white),
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
            ),

            // Lekerekített világos panel
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
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

