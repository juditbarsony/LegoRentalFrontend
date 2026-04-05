import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lego_rental_frontend/core/widgets/app_background.dart';
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
  bool _isPublic = true;
  String _visibility = 'public'; // 'public' | 'friends_only'
  String? _selectedState;

  // Availability periódusok: {'start_date': '...', 'end_date': '...'}
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Location is required.')));
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

    // Siker esetén visszanavigálás
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
      backgroundColor: const Color(0xFFF5CB58),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // ── Part number ───────────────────────────────────────
                _buildTextField(
                  controller: _setNumController,
                  label: 'Part Number (e.g. 75192-1)',
                ),
                const SizedBox(height: 12),

                // ── Title ─────────────────────────────────────────────
                _buildTextField(
                  controller: _titleController,
                  label: 'Title (if no part number)',
                ),
                const SizedBox(height: 12),

                // ── Location ──────────────────────────────────────────
                _buildTextField(
                  controller: _locationController,
                  label: 'Location *',
                ),
                const SizedBox(height: 12),

                // ── Rental price ──────────────────────────────────────
                _buildTextField(
                  controller: _rentalPriceController,
                  label: 'Rental Price Per Day (Ft)',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),

                // ── Deposit ───────────────────────────────────────────
                _buildTextField(
                  controller: _depositController,
                  label: 'Deposit (Ft)',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),

                // ── State dropdown ────────────────────────────────────
                _buildDropdown(
                  label: 'Condition',
                  value: _selectedState,
                  items: const ['NEW', 'USED', 'TRASH'],
                  onChanged: (v) => setState(() => _selectedState = v),
                ),
                const SizedBox(height: 12),

                // ── Notes ─────────────────────────────────────────────
                _buildTextField(
                  controller: _notesController,
                  label: 'Notes',
                  maxLines: 3,
                ),
                const SizedBox(height: 12),

                // ── Require scan checkbox ─────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: const Text(
                        'Require Scan Before Returning',
                        style: TextStyle(
                          color: Color(0xFF252525),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Checkbox(
                      value: _requireScan,
                      onChanged: (v) =>
                          setState(() => _requireScan = v ?? false),
                      activeColor: const Color(0xFF848383),
                    ),
                  ],
                ),

                // ── Public checkbox ───────────────────────────────────
                DropdownButtonFormField<String>(
                  value: _visibility,
                  isExpanded: true,
                  isDense: true,
                  decoration: InputDecoration(
                    labelText: 'Visibility',
                    labelStyle: const TextStyle(
                      color: Color(0xFF848383),
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_drop_down,
                      color: Color(0xFF391713)),
                  items: const [
                    DropdownMenuItem(
                      value: 'public',
                      child: Text(
                        'Public – visible to everyone',
                        style:
                            TextStyle(color: Color(0xFF391713), fontSize: 14),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'friends_only',
                      child: Text(
                        'Friends only – only visible to your friends',
                        style:
                            TextStyle(color: Color(0xFF391713), fontSize: 14),
                      ),
                    ),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _visibility = v);
                  },
                ),
                const SizedBox(height: 16),

                // ── Add availability period ────────────────────────────
                GestureDetector(
                  onTap: _addAvailablePeriod,
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 20,
                          color: Color(0xFF391713),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Add available period',
                        style: TextStyle(
                          color: Color(0xFF252525),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // ── Periódusok listája ────────────────────────────────
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 60),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: _periods.isEmpty
                      ? const Text(
                          'No periods added yet.',
                          style: TextStyle(
                            color: Color(0xFF848383),
                            fontSize: 13,
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _periods
                              .asMap()
                              .entries
                              .map(
                                (entry) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today,
                                        size: 14,
                                        color: Color(0xFF391713),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '${entry.value['start_date']}  →  ${entry.value['end_date']}',
                                          style: const TextStyle(
                                            color: Color(0xFF252525),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => setState(
                                          () => _periods.removeAt(entry.key),
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Color(0xFF848383),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                ),
                const SizedBox(height: 24),

                // ── Hiba ─────────────────────────────────────────────
                if (uploadState.errorMessage != null) ...[
                  Container(
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

                // ── Save gomb ─────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD3D3D3),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    onPressed: uploadState.isLoading ? null : _submit,
                    child: uploadState.isLoading
                        ? const CircularProgressIndicator(
                            color: Color(0xFF391713),
                          )
                        : const Text(
                            'Save',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF391713),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Helper widgetek ───────────────────────────────────────────────────────

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF848383), fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: DropdownButton<String>(
        value: value,
        hint: Text(
          label,
          style: const TextStyle(color: Color(0xFF848383), fontSize: 14),
        ),
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF391713)),
        items: [
          DropdownMenuItem<String>(
            value: null,
            child: Text(
              'Select $label',
              style: const TextStyle(color: Color(0xFF848383), fontSize: 14),
            ),
          ),
          ...items.map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(color: Color(0xFF391713), fontSize: 14),
              ),
            ),
          ),
        ],
        onChanged: onChanged,
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
