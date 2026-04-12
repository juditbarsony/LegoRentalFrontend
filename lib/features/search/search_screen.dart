import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lego_rental_frontend/core/theme/app_colors.dart';
import 'package:lego_rental_frontend/core/theme/app_radius.dart';
import 'package:lego_rental_frontend/core/theme/app_spacing.dart';
import 'package:lego_rental_frontend/core/theme/app_text_styles.dart';
import 'package:lego_rental_frontend/core/widgets/app_background.dart';
import 'package:lego_rental_frontend/core/widgets/app_dropdown.dart';
import 'package:lego_rental_frontend/core/widgets/app_primary_button.dart';
import 'package:lego_rental_frontend/core/widgets/app_section_card.dart';
import 'package:lego_rental_frontend/core/widgets/section_header.dart';
import 'package:lego_rental_frontend/features/home/home_screen.dart';
import 'package:lego_rental_frontend/features/set_detail/set_detail_screen.dart';
import 'package:lego_rental_frontend/features/sets/sets/sets_providers.dart';
import 'package:lego_rental_frontend/features/sets/widgets/lego_set_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  String? selectedStatus;
  String? selectedLocation;

  RangeValues _priceRange = const RangeValues(0, 5000);
  DateTime? _rentalStart;
  DateTime? _rentalEnd;

  Key _calendarKey = UniqueKey();

  final _searchController = TextEditingController();

  final _searchFocusNode = FocusNode();

  static const _statusItems = ['NEW', 'USED', 'TRASH'];
  static const _locationItems = [
    'Budapest',
    'Debrecen',
    'Miskolc',
    'Pécs',
    'Győr',
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(setsProvider.notifier).loadSets();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  List<String> _buildSetNumberSuggestions(List<dynamic> items, String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return const [];

    final matches = items
        .map((item) => item.setNum?.toString() ?? '')
        .where((setNum) => setNum.isNotEmpty)
        .where((setNum) => setNum.toLowerCase().contains(normalized))
        .toSet()
        .toList()
      ..sort();

    return matches.take(8).toList();
  }

  String _priceLabel() {
    final start = _priceRange.start.toInt();
    final end = _priceRange.end.toInt();

    if (start <= 0 && end >= 5000) {
      return 'Any price';
    }
    if (end >= 5000) {
      return '$start - 5000+ Ft';
    }
    return '$start - $end Ft';
  }

  void _applyFilters() {
    final keyword = _searchController.text.trim();

    ref.read(setsProvider.notifier).loadSets(
          keyword: keyword.isEmpty ? null : keyword,
          setStatus: selectedStatus,
          location: selectedLocation,
          maxPrice: _priceRange.end >= 5000 ? null : _priceRange.end,
          // availableFrom: _rentalStart,
          // availableTo: _rentalEnd,
        );
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      selectedStatus = null;
      selectedLocation = null;
      _priceRange = const RangeValues(0, 5000);
      _rentalStart = null;
      _rentalEnd = null;
      _calendarKey = UniqueKey();
    });

    ref.read(setsProvider.notifier).loadSets();
  }

  @override
  Widget build(BuildContext context) {
    final setsState = ref.watch(setsProvider);

    return Scaffold(
      backgroundColor: AppColors.brandHeader,
      body: AppBackground(
        title: 'Advanced Search',
        onBack: null,
        onHome: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
          );
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.lg),
              _buildSearchField(setsState.items),
              const SizedBox(height: AppSpacing.xl),
              SectionHeader(
                title: 'Filters',
                trailing: Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: _resetFilters,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                    child: const Text('Reset'),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppDropdown<String>(
                      hintText: 'Status',
                      value: selectedStatus,
                      items: _statusItems
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => selectedStatus = value),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppDropdown<String>(
                      hintText: 'Location',
                      value: selectedLocation,
                      items: _locationItems
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => selectedLocation = value),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Price per day',
                          style: TextStyle(
                            color: AppColors.text,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warningSoft,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            _priceLabel(),
                            style: AppTextStyles.meta.copyWith(
                              color: AppColors.text,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4,
                        rangeThumbShape: const RoundRangeSliderThumbShape(
                          enabledThumbRadius: 8,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 14,
                        ),
                        activeTrackColor: AppColors.text,
                        inactiveTrackColor: AppColors.disabled,
                        thumbColor: const Color(0xFFF4C542),
                        overlayColor: const Color(0xFFF4C542).withOpacity(0.18),
                      ),
                      child: RangeSlider(
                        values: _priceRange,
                        min: 0,
                        max: 5000,
                        divisions: 20,
                        onChanged: (values) =>
                            setState(() => _priceRange = values),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const Text(
                      'Rental period',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AvailabilityCalendar(
                      key: _calendarKey,
                      onRangeSelected: (start, end) {
                        setState(() {
                          _rentalStart = start;
                          _rentalEnd = end;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Column(
                children: [
                  AppPrimaryButton(
                    label: 'Apply',
                    onPressed: _applyFilters,
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              const SectionHeader(title: 'Results'),
              if (setsState.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(
                      color: AppColors.text,
                    ),
                  ),
                )
              else if (setsState.error != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    setsState.error!,
                    style: AppTextStyles.body.copyWith(
                      color: Colors.red,
                    ),
                  ),
                )
              else if (setsState.items.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Text(
                    'Nincs a keresésnek megfelelő készlet.',
                    style: AppTextStyles.body,
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: setsState.items.length,
                  itemBuilder: (context, index) {
                    final set = setsState.items[index];
                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacing.md,
                      ),
                      child: LegoSetCard(
                        set: set,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SetDetailScreen(setId: set.id),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.chevron_left),
                    color: AppColors.text,
                  ),
                  const Text(
                    '1',
                    style: TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '2',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '3',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.chevron_right),
                    color: AppColors.text,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField(List<dynamic> items) {
    return RawAutocomplete<String>(
      textEditingController: _searchController,
      focusNode: _searchFocusNode,
      optionsBuilder: (TextEditingValue textEditingValue) {
        return _buildSetNumberSuggestions(items, textEditingValue.text);
      },
      onSelected: (String selection) {
        _searchController.text = selection;
        _searchController.selection = TextSelection.fromPosition(
          TextPosition(offset: selection.length),
        );
        _applyFilters();
      },
      fieldViewBuilder: (
        context,
        textEditingController,
        focusNode,
        onFieldSubmitted,
      ) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
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
            controller: textEditingController,
            focusNode: focusNode,
            onSubmitted: (_) {
              onFieldSubmitted();
              _applyFilters();
            },
            onChanged: (_) => setState(() {}),
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
              hintStyle: AppTextStyles.body.copyWith(
                color: AppColors.textMuted,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: Color(0xFF5C5C5C),
                size: 22,
              ),
              suffixIcon: textEditingController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        textEditingController.clear();
                        setState(() {});
                      },
                      icon: const Icon(
                        Icons.clear,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        final optionList = options.toList();

        if (optionList.isEmpty) {
          return const SizedBox.shrink();
        }

        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              width: MediaQuery.of(context).size.width - 32,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: const Color(0xFFF0E6B8)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 6),
                shrinkWrap: true,
                itemCount: optionList.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: AppColors.border),
                itemBuilder: (context, index) {
                  final option = optionList[index];
                  return ListTile(
                    dense: true,
                    title: Text(
                      option,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}
