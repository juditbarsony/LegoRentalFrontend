import 'package:flutter/material.dart';
import 'package:lego_rental_frontend/core/widgets/app_background.dart';
import 'package:lego_rental_frontend/features/main/main_screen.dart';




class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5CB58),
      body: AppBackground(
        title: 'Home',
        onBack: null, // nincs vissza gomb a home-on
        onHome: null,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Keresőmező + settings ikon
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF3E9B5),
                        hintText: 'Search LEGO sets...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const MainScreen()),
                      );
                    },
                    icon: const Icon(Icons.tune),
                    color: const Color(0xFF391713),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Let's Play! cím
              const Text(
                'Let\'s Play!',
                style: TextStyle(
                  color: Color(0xFF391713),
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Find your next LEGO adventure',
                style: TextStyle(
                  color: Color(0xFF252525),
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                ),
              ),

              const SizedBox(height: 24),

              // Browse Categories cím
              const Text(
                'Browse Categories',
                style: TextStyle(
                  color: Color(0xFF391713),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              // Kategória lista vízszintesen
              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    _CategoryCard(title: 'City', color: Color(0xFFFF6B6B)),
                    _CategoryCard(title: 'Star Wars', color: Color(0xFF4ECDC4)),
                    _CategoryCard(title: 'Technic', color: Color(0xFFFFE66D)),
                    _CategoryCard(title: 'Friends', color: Color(0xFFA8E6CF)),
                    _CategoryCard(title: 'Creator', color: Color(0xFFFFAA80)),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Placeholder a készlet kártyáknak
              // Available nearby cím
              const Text(
                'Available nearby',
                style: TextStyle(
                  color: Color(0xFF391713),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              // Készlet kártyák rácsban
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.75,
                children: const [
                  _LegoSetCard(
                    title: 'LEGO City Police Station',
                    price: '3500 Ft/week',
                  ),
                  _LegoSetCard(
                    title: 'Star Wars Millennium Falcon',
                    price: '5000 Ft/week',
                  ),
                  _LegoSetCard(
                    title: 'Technic Porsche 911',
                    price: '4500 Ft/week',
                  ),
                  _LegoSetCard(
                    title: 'Friends Heartlake City',
                    price: '2800 Ft/week',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // 0 = Search, ez lesz „alap” tab, ha átlépsz
        onTap: (index) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => MainScreen(initialIndex: index)),
          );
        },
        selectedItemColor: const Color(0xFF391713),
        unselectedItemColor: const Color(0xFF848383),
        backgroundColor: const Color(0xFFF5F5F5),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Upload'),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Messages',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final Color color;

  const _CategoryCard({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _LegoSetCard extends StatelessWidget {
  final String title;
  final String price;

  const _LegoSetCard({required this.title, required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3E9B5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Placeholder kép
          Expanded(
            flex: 3,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFE0E0E0),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: const Center(
                child: Icon(Icons.image, size: 48, color: Colors.grey),
              ),
            ),
          ),
          // Szöveg rész
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF391713),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    price,
                    style: const TextStyle(
                      color: Color(0xFF848383),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
