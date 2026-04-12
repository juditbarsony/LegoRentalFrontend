import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lego_rental_frontend/core/theme/app_colors.dart';
import 'package:lego_rental_frontend/core/widgets/app_background.dart';
import 'package:lego_rental_frontend/core/widgets/app_primary_button.dart';
import 'package:lego_rental_frontend/core/widgets/app_text_field.dart';
import 'package:lego_rental_frontend/core/widgets/app_dropdown.dart';
import 'package:lego_rental_frontend/core/widgets/app_section_card.dart';
import 'package:lego_rental_frontend/features/home/home_screen.dart';
import 'package:lego_rental_frontend/features/upload/upload_providers.dart';

class UploadScreen extends ConsumerStatefulWidget {
  const UploadScreen({super.key});

  @override
  ConsumerState<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends ConsumerState<UploadScreen> {
  final _setNumController = TextEditingController();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _rentalPriceController = TextEditingController();
  final _depositController = TextEditingController();
  final _notesController = TextEditingController();

  bool _requireScan = false;
  String _visibility = 'public'; // 'public' | 'friends_only'
  String? _selectedState;

  // Availability periods: {'start_date': '...', 'end_date': '...'}
  final List<Map<String, String>> _periods = [];

  @override
  void dispose() {
    _setNumController.dispose();
    _titleController.dispose();
    _locationController.dispose();
    _rentalPriceController.dispose();
    _depositController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _addAvailablePeriod() async {
    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.6,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'Select available period',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: AvailabilityCalendarForUpload(
                  onPeriodSelected: (start, end) {
                    Navigator.pop(ctx, {
                      'start_date': start.toIso8601String().substring(0, 10),
                      'end_date': end.toIso8601String().substring(0, 10),
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (result != null) {
      setState(() => _periods.add(result));
    }
  }

  void _submit() {
    final location = _locationController.text.trim();
    final rentalPrice =
        double.tryParse(_rentalPriceController.text.trim()) ?? 0.0;
    final deposit = double.tryParse(_depositController.text.trim()) ?? 0.0;
    final setNum = _setNumController.text.trim();
    final title = _titleController.text.trim();
    final isPublic = _visibility == 'public';

    if (location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location is required.')),
      );
      return;
    }
    if (setNum.isEmpty && title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Either Part Number or Title is required.'),
        ),
      );
      return;
    }

    ref.read(uploadProvider.notifier).uploadSet(
          setNum: setNum.isEmpty ? null : setNum,
          title: title.isEmpty ? null : title,
          location: location,
          rentalPrice: rentalPrice,
          deposit: deposit,
          scanRequired: _requireScan,
          isPublic: isPublic,
          state: _selectedState,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          availabilityPeriods: _periods,
        );
  }

  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(uploadProvider);

    ref.listen(uploadProvider, (_, next) {
      if (next.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Set uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
        ref.read(uploadProvider.notifier).reset();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.brandHeader,
      body: AppBackground(
        title: 'Upload Set',
        onBack: () => Navigator.pop(context),
        onHome: () => Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 12),

                // BASIC INFO
                AppSectionCard(
                  title: 'Basic info',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextField(
                        label: 'Part number',
                        hintText: 'e.g. 75192-1',
                        controller: _setNumController,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        label: 'Title (if no part number)',
                        hintText: 'Set title',
                        controller: _titleController,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        label: 'Location *',
                        hintText: 'City or area',
                        controller: _locationController,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // RENTAL DETAILS
                AppSectionCard(
                  title: 'Rental details',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextField(
                        label: 'Rental price per day (Ft)',
                        hintText: 'Optional',
                        controller: _rentalPriceController,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        label: 'Deposit (Ft)',
                        hintText: 'Optional',
                        controller: _depositController,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      AppDropdown<String>(
                        label: 'Condition',
                        hintText: 'Select condition',
                        value: _selectedState,
                        items: const ['NEW', 'USED', 'TRASH']
                            .map(
                              (item) => DropdownMenuItem<String>(
                                value: item,
                                child: Text(
                                  item,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() => _selectedState = value);
                        },
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        label: 'Notes',
                        hintText: 'Anything renters should know',
                        controller: _notesController,
                        keyboardType: TextInputType.multiline,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Require scan before returning',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppColors.text,
                                    fontSize: 14,
                                  ),
                            ),
                          ),
                          Checkbox(
                            value: _requireScan,
                            activeColor: AppColors.primary,
                            onChanged: (v) => setState(
                              () => _requireScan = v ?? false,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      AppDropdown<String>(
                        label: 'Visibility',
                        hintText: 'Who can see this set',
                        value: _visibility,
                        items: const [
                          DropdownMenuItem(
                            value: 'public',
                            child: Text(
                              'Public – visible to everyone',
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'friends_only',
                            child: Text(
                              'Friends only – visible to your friends',
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _visibility = value);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // AVAILABILITY
                AppSectionCard(
                  title: 'Availability',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _addAvailablePeriod,
                        icon: const Icon(Icons.add),
                        label: const Text('Add available period'),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(minHeight: 60),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: _periods.isEmpty
                            ? Text(
                                'No periods added yet.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppColors.textMuted,
                                    ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: _periods
                                    .asMap()
                                    .entries
                                    .map(
                                      (entry) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 6),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.calendar_today,
                                              size: 14,
                                              color: AppColors.text,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                '${entry.value['start_date']} → ${entry.value['end_date']}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color: AppColors.text,
                                                    ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.close,
                                                size: 16,
                                                color: AppColors.textMuted,
                                              ),
                                              onPressed: () => setState(
                                                () => _periods
                                                    .removeAt(entry.key),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                if (uploadState.errorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Text(
                      uploadState.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                AppPrimaryButton(
                  label: uploadState.isLoading ? 'Saving…' : 'Save',
                  onPressed: uploadState.isLoading ? null : _submit,
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── AvailabilityCalendarForUpload ────────────────────────────────────────────

class AvailabilityCalendarForUpload extends StatefulWidget {
  final void Function(DateTime start, DateTime end) onPeriodSelected;
  const AvailabilityCalendarForUpload({required this.onPeriodSelected});

  @override
  State<AvailabilityCalendarForUpload> createState() =>
      _AvailabilityCalendarForUploadState();
}

class _AvailabilityCalendarForUploadState
    extends State<AvailabilityCalendarForUpload> {
  int currentYear = DateTime.now().year;
  int currentMonth = DateTime.now().month;
  DateTime? startDate;
  DateTime? endDate;

  void _selectDay(int day) {
    final selected = DateTime(currentYear, currentMonth, day);
    setState(() {
      if (startDate == null || (startDate != null && endDate != null)) {
        startDate = selected;
        endDate = null;
      } else if (selected.isBefore(startDate!)) {
        endDate = startDate;
        startDate = selected;
      } else {
        endDate = selected;
      }
    });
    if (startDate != null && endDate != null) {
      widget.onPeriodSelected(startDate!, endDate!);
    }
  }

  bool _isInRange(int day) {
    if (startDate == null) return false;
    final date = DateTime(currentYear, currentMonth, day);
    if (endDate == null) return date == startDate;
    return !date.isBefore(startDate!) && !date.isAfter(endDate!);
  }

  int _daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final days = _daysInMonth(currentYear, currentMonth);
    final firstWeekday = DateTime(currentYear, currentMonth, 1).weekday;

    return Column(
      children: [
        // ── Hónap navigáció ────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () => setState(() {
                if (currentMonth == 1) {
                  currentMonth = 12;
                  currentYear--;
                } else {
                  currentMonth--;
                }
              }),
              icon: const Icon(Icons.chevron_left, color: Color(0xFF391713)),
            ),
            Text(
              '${_monthName(currentMonth)} $currentYear',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            IconButton(
              onPressed: () => setState(() {
                if (currentMonth == 12) {
                  currentMonth = 1;
                  currentYear++;
                } else {
                  currentMonth++;
                }
              }),
              icon: const Icon(Icons.chevron_right, color: Color(0xFF391713)),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // ── Napok rács ─────────────────────────────────────────
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: days + firstWeekday - 1,
            itemBuilder: (context, index) {
              if (index < firstWeekday - 1) return const SizedBox();
              final day = index - firstWeekday + 2;
              final inRange = _isInRange(day);
              return GestureDetector(
                onTap: () => _selectDay(day),
                child: Container(
                  decoration: BoxDecoration(
                    color: inRange ? const Color(0xFF848383) : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: TextStyle(
                        color: inRange ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
