import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lego_rental_frontend/core/widgets/app_background.dart';
import 'package:lego_rental_frontend/features/home/home_screen.dart';
import 'package:lego_rental_frontend/features/sets/sets/sets_providers.dart';
import 'package:lego_rental_frontend/features/sets/widgets/lego_set_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  String? selectedCategory;
  String? selectedStatus;
  String? selectedPrice;
  String? selectedLocation;

  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // első betöltés: keyword nélkül
    Future.microtask(() {
     // ref.read(setsProvider.notifier).loadSets(); kelleni fog!!!!
    });
  }

  @override
  Widget build(BuildContext context) {
    final setsState = ref.watch(setsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5CB58),
      body: AppBackground(
        title: 'Search & Filter',
        onBack: null,
        onHome: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
          );
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Search mező
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF3E9B5),
                  hintText: 'Search',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      final keyword = _searchController.text;
                      ref
                          .read(setsProvider.notifier)
                          .loadSets(keyword: keyword);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Filter cím
              const Text(
                'Filter:',
                style: TextStyle(
                  color: Color(0xFF391713),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 12),

              // Category dropdown
              _FilterDropdown(
                label: 'Category',
                value: selectedCategory,
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
              ),

              const SizedBox(height: 12),

              // Status dropdown
              _FilterDropdown(
                label: 'Status',
                value: selectedStatus,
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value;
                  });
                },
              ),

              const SizedBox(height: 12),

              // Price dropdown
              _FilterDropdown(
                label: 'Price',
                value: selectedPrice,
                onChanged: (value) {
                  setState(() {
                    selectedPrice = value;
                  });
                },
              ),

              const SizedBox(height: 12),

              // Location dropdown
              _FilterDropdown(
                label: 'Location',
                value: selectedLocation,
                onChanged: (value) {
                  setState(() {
                    selectedLocation = value;
                  });
                },
              ),

              const SizedBox(height: 24),

              // Apply gomb
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD3D3D3),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 48,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  onPressed: () {
                    // TODO: filter logic
                  },
                  child: const Text(
                    'Apply',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF391713),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Placeholder a térképnek és listának
              Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text('Nearby LEGO Renters map - következő lépés'),
                ),
              ),

              const SizedBox(height: 24),

              /* Container(
                height: 300,
                color: Colors.grey[300],
                child: const Center(
                  child: Text('Set kártyák listája - harmadik lépés'),
                ),
              ), */
              // Set kártyák listája
              if (setsState.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (setsState.error != null)
                Center(
                  child: Text(
                    setsState.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              else if (setsState.items.isEmpty)
                const Center(
                  child: Text('Nincs a keresésnek megfelelő készlet.'),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: setsState.items.length,
                  itemBuilder: (context, index) {
                    final set = setsState.items[index];
                    return LegoSetCard(
                      set: set,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/set-detail',
                          arguments: set.id,
                        );
                      },
                    );
                  },
                ),

              const SizedBox(height: 24),

              // Lapozás
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      // TODO: előző oldal
                    },
                    icon: const Icon(Icons.chevron_left),
                    color: const Color(0xFF391713),
                  ),
                  const Text(
                    '1',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 12),
                  const Text('2'),
                  const SizedBox(width: 12),
                  const Text('3'),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () {
                      // TODO: következő oldal
                    },
                    icon: const Icon(Icons.chevron_right),
                    color: const Color(0xFF391713),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final ValueChanged<String?> onChanged;

  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[400]!, width: 1)),
      ),
      child: DropdownButton<String>(
        value: value,
        hint: Text(
          label,
          style: const TextStyle(color: Color(0xFF391713), fontSize: 14),
        ),
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF391713)),
        items: const [], // később ide jönnek az opciók
        onChanged: onChanged,
      ),
    );
  }
}
