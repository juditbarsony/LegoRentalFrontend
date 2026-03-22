import 'package:flutter/material.dart';
import 'package:lego_rental_frontend/core/models/lego_set_model.dart';
import 'package:lego_rental_frontend/core/services/api_service.dart';
import 'package:lego_rental_frontend/core/widgets/app_background.dart';
import 'package:lego_rental_frontend/features/main/main_screen.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<LegoSetModel> _sets = [];
  bool _isLoading = true;
  String? _error;
  int? _selectedThemeId;

  static const List<Map<String, dynamic>> _categories = [
    {'label': 'City',        'themeId': 672, 'color': Color(0xFFFF6B6B)},
    {'label': 'Star Wars',   'themeId': 171, 'color': Color(0xFF4ECDC4)},
    {'label': 'Technic',     'themeId': 1,   'color': Color(0xFFFFE66D)},
    {'label': 'Friends',     'themeId': 246, 'color': Color(0xFFA8E6CF)},
    {'label': 'Creator',     'themeId': 22,  'color': Color(0xFFFFAA80)},
    {'label': 'Harry Potter','themeId': 406, 'color': Color(0xFF9B59B6)},
  ];

  @override
  void initState() {
    super.initState();
    _loadSets();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSets({String? keyword, int? themeId}) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      // Ha a keyword "12345-1" formátumú → set_num keresés
      final isSetNum = keyword != null &&
          RegExp(r'^\d{4,6}-\d$').hasMatch(keyword);
      final results = await ApiService.fetchSets(
        keyword: isSetNum ? null : keyword,
        setNum: isSetNum ? keyword : null,
        themeId: themeId,
        limit: 20,
      );
      setState(() {
        _sets = results.map((e) => LegoSetModel.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
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
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onSubmitted: _onSearch,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF3E9B5),
                        hintText: 'Search by name or set number...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  _loadSets(themeId: _selectedThemeId);
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const MainScreen()),
                    ),
                    icon: const Icon(Icons.tune),
                    color: const Color(0xFF391713),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              const Text(
                "Let's Play!",
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
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = _selectedThemeId == cat['themeId'];
                    return GestureDetector(
                      onTap: () => _onCategoryTap(cat['themeId'] as int),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 90,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: cat['color'] as Color,
                          borderRadius: BorderRadius.circular(14),
                          border: isSelected
                              ? Border.all(
                                  color: const Color(0xFF391713), width: 3)
                              : null,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  )
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            cat['label'] as String,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              shadows: isSelected
                                  ? [
                                      const Shadow(
                                        color: Colors.black26,
                                        blurRadius: 4,
                                      )
                                    ]
                                  : null,
                            ),
                            textAlign: TextAlign.center,
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
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(
                      color: Color(0xFF391713),
                    ),
                  ),
                )
              else if (_error != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 48),
                        const SizedBox(height: 8),
                        Text(
                          _error!,
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
              else if (_sets.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'No LEGO sets found.',
                      style: TextStyle(
                        color: Color(0xFF848383),
                        fontSize: 16,
                      ),
                    ),
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _sets.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  itemBuilder: (context, index) {
                    return LegoSetCard(legoSet: _sets[index]);
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
              icon: Icon(Icons.qr_code_scanner), label: 'Scan'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class LegoSetCard extends StatelessWidget {
  final LegoSetModel legoSet;

  const LegoSetCard({super.key, required this.legoSet});

  @override
  Widget build(BuildContext context) {
    final priceText = legoSet.rentalPrice > 0
        ? '${legoSet.rentalPrice.toStringAsFixed(0)} Ft/week'
        : 'Ár nem megadva';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3E9B5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kép rész
          AspectRatio(
            aspectRatio: 1.1,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: (legoSet.imgUrl != null && legoSet.imgUrl!.isNotEmpty)
                  ? Image.network(
                      legoSet.imgUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
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
          // Szöveg rész
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  legoSet.title,
                  style: const TextStyle(
                    color: Color(0xFF391713),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (legoSet.setNum != null && legoSet.setNum!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    '#${legoSet.setNum}',
                    style: const TextStyle(
                      color: Color(0xFF848383),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                if (legoSet.location.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 12, color: Color(0xFF848383)),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          legoSet.location,
                          style: const TextStyle(
                            color: Color(0xFF848383),
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  priceText,
                  style: const TextStyle(
                    color: Color(0xFF391713),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
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
            if (legoSet.setNum != null && legoSet.setNum!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                legoSet.setNum!,
                style: const TextStyle(
                  color: Color(0xFF391713),
                  fontSize: 11,
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

