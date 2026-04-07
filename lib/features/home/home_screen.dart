import 'package:flutter/material.dart';
//import 'package:lego_rental_frontend/core/models/lego_set_model.dart';
//import 'package:lego_rental_frontend/core/services/api_service.dart';
import 'package:lego_rental_frontend/core/widgets/app_background.dart';
import 'package:lego_rental_frontend/features/main/main_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lego_rental_frontend/features/set_detail/set_detail_screen.dart';
import 'package:lego_rental_frontend/features/sets/sets/sets_providers.dart';
import 'package:lego_rental_frontend/features/home/widgets/set_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  int? _selectedThemeId;

  static const List<Map<String, dynamic>> _categories = [
    {'label': 'City', 'themeId': 672, 'color': Color(0xFFF7E7B4)},
    {'label': 'Star Wars', 'themeId': 171, 'color': Color(0xFFF2D98A)},
    {'label': 'Technic', 'themeId': 1, 'color': Color(0xFFEBCB63)},
    {'label': 'Friends', 'themeId': 246, 'color': Color(0xFFE2BE58)},
    {'label': 'Creator', 'themeId': 22, 'color': Color(0xFFD6AF4B)},
    {'label': 'Harry Potter', 'themeId': 406, 'color': Color(0xFFC99D3E)},
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadSets());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadSets({String? keyword, int? themeId}) {
    ref
        .read(setsProvider.notifier)
        .loadSets(keyword: keyword, themeId: themeId);
  }

  void _onSearch(String value) {
    _loadSets(keyword: value.trim(), themeId: _selectedThemeId);
  }

  void _onCategoryTap(int themeId) {
    setState(() {
      _selectedThemeId = _selectedThemeId == themeId ? null : themeId;
    });
    _loadSets(
      keyword: _searchController.text.trim(),
      themeId: _selectedThemeId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final setsState = ref.watch(setsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5CB58),
      body: AppBackground(
        title: 'Home',
        onBack: null,
        onHome: null,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Keresőmező
// Keresőmező
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFFF0E6B8),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onSubmitted: _onSearch,
                        onChanged: (value) => setState(() {}),
                        textInputAction: TextInputAction.search,
                        style: const TextStyle(
                          color: Color(0xFF252525),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.transparent,
                          hintText: 'Search by name or set number...',
                          hintStyle: const TextStyle(
                            color: Color(0xFF848383),
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color(0xFF5C5C5C),
                            size: 22,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.clear,
                                    color: Color(0xFF848383),
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                    _loadSets(themeId: _selectedThemeId);
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    height: 52,
                    width: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFF0E6B8),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const MainScreen()),
                      ),
                      icon: const Icon(
                        Icons.tune_rounded,
                        color: Color(0xFF391713),
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              const Text(
                'Discover LEGO sets',
                style: TextStyle(
                  color: Color(0xFF391713),
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Browse categories and available rentals',
                style: TextStyle(
                  color: Color(0xFF252525),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                'Browse Categories',
                style: TextStyle(
                  color: Color(0xFF391713),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              // Kategória csík
              SizedBox(
                height: 72,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = _selectedThemeId == cat['themeId'];

                    return GestureDetector(
                      onTap: () => _onCategoryTap(cat['themeId'] as int),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOut,
                        width: 104,
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFE4C766)
                              : const Color(0xFFF6EFCF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF391713)
                                : const Color(0xFFE7DCA8),
                            width: isSelected ? 1.6 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.10),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            cat['label'] as String,
                            style: TextStyle(
                              color: const Color(0xFF391713),
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Szekció cím
              Text(
                _selectedThemeId != null
                    ? '${_categories.firstWhere((c) => c['themeId'] == _selectedThemeId)['label']} sets'
                    : _searchController.text.trim().isEmpty
                        ? 'Available sets'
                        : 'Results for "${_searchController.text.trim()}"',
                style: const TextStyle(
                  color: Color(0xFF391713),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              // Tartalom
              if (setsState.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(color: Color(0xFF391713)),
                  ),
                )
              else if (setsState.error != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          setsState.error!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _loadSets(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (setsState.items.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'No LEGO sets found.',
                      style: TextStyle(color: Color(0xFF848383), fontSize: 16),
                    ),
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: setsState.items.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  itemBuilder: (context, index) {
                    return SetCard(
                      set: setsState.items[index],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SetDetailScreen(
                              setId: setsState.items[index].id,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainScreen(initialIndex: index)),
        ),
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
