import 'package:flutter/material.dart';
//import 'package:lego_rental_frontend/features/home/home_screen.dart';
//import 'package:lego_rental_frontend/features/home/home_screen.dart';
import 'package:lego_rental_frontend/features/search/search_screen.dart';
import 'package:lego_rental_frontend/features/upload/upload_screen.dart';
import 'package:lego_rental_frontend/features/scan/scan_screen.dart';
import 'package:lego_rental_frontend/features/messages/messages_screen.dart';
import 'package:lego_rental_frontend/features/profile/profile_screen.dart';
//import 'package:lego_rental_frontend/features/set_detail/set_detail_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _screens = const [
    SearchScreen(),
    UploadScreen(),
    ScanScreen(),
    MessagesScreen(),
    ProfileScreen(),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: const Color(0xFF391713),
        unselectedItemColor: const Color(0xFF848383),
        backgroundColor: const Color(0xFFF5F5F5),
        type: BottomNavigationBarType.fixed, // hogy 5 gomb is elférjen
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: 'Upload',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
