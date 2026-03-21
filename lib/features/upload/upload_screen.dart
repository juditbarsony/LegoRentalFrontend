import 'package:flutter/material.dart';
import 'package:lego_rental_frontend/core/widgets/app_background.dart';
import 'package:lego_rental_frontend/features/home/home_screen.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  bool requireScan = false;
  bool isPublic = true;

  final List<String> _periods = []; // ide gyűjtjük a szöveges intervallumokat

  void _addAvailablePeriod() async {
    // teljes képernyős bottom sheet / dialog a naptárral
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.6,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
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
                    child: _AvailabilityCalendarForUpload(
                      onPeriodSelected: (start, end) {
                        final text =
                            '${start.toIso8601String().substring(0, 10)} - ${end.toIso8601String().substring(0, 10)}';
                        Navigator.pop(context, text);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        _periods.add(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5CB58),
      body: AppBackground(
        title: 'Upload\nLego Set',
        onBack: () => Navigator.pop(context),
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
              _DropdownField(label: 'Part number'),
              const SizedBox(height: 12),
              _DropdownField(label: 'Title'),
              const SizedBox(height: 12),
              _TextField(label: 'Location'),
              const SizedBox(height: 12),
              _TextField(label: 'Rental Price Per Day'),
              const SizedBox(height: 12),
              _TextField(label: 'Deposit'),
              const SizedBox(height: 12),

              // Require Scan Before Returning
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Require Scan Before Returning',
                      style: const TextStyle(
                        color: Color(0xFF252525),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Checkbox(
                    value: requireScan,
                    onChanged: (value) {
                      setState(() {
                        requireScan = value ?? false;
                      });
                    },
                    activeColor: const Color(0xFF848383),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _TextField(label: 'Number of Items'),
              const SizedBox(height: 12),
              _TextField(label: 'State'),
              const SizedBox(height: 12),
              _DropdownField(label: 'Missing Items'),
              const SizedBox(height: 12),
              _TextField(label: 'Notes'),
              const SizedBox(height: 16),

              // Add available period
              // Add available period
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
                      style: TextStyle(color: Color(0xFF252525), fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // nagy fehér „textarea” – ide írjuk bele a kijelölt időszakokat
              Container(
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                padding: const EdgeInsets.all(12),
                child: _periods.isEmpty
                    ? const Text('', style: TextStyle(color: Color(0xFF848383)))
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _periods
                              .map(
                                (p) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    p,
                                    style: const TextStyle(
                                      color: Color(0xFF252525),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
              ),

              Row(
                children: [
                  /* Container(
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
                  ), */
/*                   const SizedBox(width: 8),
                  const Text(
                    'Add available period',
                    style: TextStyle(color: Color(0xFF252525), fontSize: 14),
                  ), */
                ],
              ),
              const SizedBox(height: 12),

              // nagy fehér text area
/*               Container(
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
              ), */
              const SizedBox(height: 16),

              // Public + checkbox
              Row(
                children: [
                  const Text(
                    'Public',
                    style: TextStyle(color: Color(0xFF252525), fontSize: 14),
                  ),
                  const Spacer(),
                  Checkbox(
                    value: isPublic,
                    onChanged: (value) {
                      setState(() {
                        isPublic = value ?? true;
                      });
                    },
                    activeColor: const Color(0xFF848383),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Save button
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
                  onPressed: () {
                    // TODO: mentés API-hoz kötve
                  },
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF391713),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final String label;

  const _TextField({required this.label});

  @override
  Widget build(BuildContext context) {
    return TextField(
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
}

class _DropdownField extends StatelessWidget {
  final String label;

  const _DropdownField({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: DropdownButton<String>(
        value: null,
        hint: Text(
          label,
          style: const TextStyle(color: Color(0xFF848383), fontSize: 14),
        ),
        isExpanded: true,
        underline: const SizedBox.shrink(),
        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF391713)),
        items: const [], // később opciók API-ból
        onChanged: (_) {},
      ),
    );
  }
}

class _AvailabilityCalendarForUpload extends StatefulWidget {
  final void Function(DateTime start, DateTime end) onPeriodSelected;

  const _AvailabilityCalendarForUpload({
    required this.onPeriodSelected,
  });

  @override
  State<_AvailabilityCalendarForUpload> createState() =>
      _AvailabilityCalendarForUploadState();
}

class _AvailabilityCalendarForUploadState
    extends State<_AvailabilityCalendarForUpload> {
  int currentYear = DateTime.now().year;
  int currentMonth = DateTime.now().month;

  DateTime? startDate;
  DateTime? endDate;

  void _selectDay(int day) {
    final selectedDate = DateTime(currentYear, currentMonth, day);

    setState(() {
      if (startDate == null || (startDate != null && endDate != null)) {
        startDate = selectedDate;
        endDate = null;
      } else {
        if (selectedDate.isBefore(startDate!)) {
          endDate = startDate;
          startDate = selectedDate;
        } else {
          endDate = selectedDate;
        }
      }
    });

    if (startDate != null && endDate != null) {
      widget.onPeriodSelected(startDate!, endDate!);
    }
  }

  bool _isInRange(int day) {
    if (startDate == null) return false;
    final date = DateTime(currentYear, currentMonth, day);
    if (endDate == null) {
      return date.isAtSameMomentAs(startDate!);
    }
    return !date.isBefore(startDate!) && !date.isAfter(endDate!);
  }

  int _daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

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

    return Column(
      children: [
        // Year + month selector (egyszerűsítve)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  if (currentMonth == 1) {
                    currentMonth = 12;
                    currentYear--;
                  } else {
                    currentMonth--;
                  }
                });
              },
              icon: const Icon(Icons.chevron_left, color: Color(0xFF391713)),
            ),
            Text(
              '${_monthName(currentMonth)} $currentYear',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  if (currentMonth == 12) {
                    currentMonth = 1;
                    currentYear++;
                  } else {
                    currentMonth++;
                  }
                });
              },
              icon: const Icon(Icons.chevron_right, color: Color(0xFF391713)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: days,
            itemBuilder: (context, index) {
              final day = index + 1;
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

