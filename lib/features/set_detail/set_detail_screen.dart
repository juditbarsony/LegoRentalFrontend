import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lego_rental_frontend/core/widgets/app_background.dart';
import 'package:lego_rental_frontend/features/home/home_screen.dart';
import 'package:lego_rental_frontend/features/main/main_screen.dart';
import 'package:lego_rental_frontend/features/set_detail/set_detail_providers.dart';
import 'package:lego_rental_frontend/features/sets/data/lego_set.dart';

class SetDetailScreen extends ConsumerStatefulWidget {
  const SetDetailScreen({super.key});

  @override
  ConsumerState<SetDetailScreen> createState() => _SetDetailScreenState();
}

class _SetDetailScreenState extends ConsumerState<SetDetailScreen> {
  int? _setId;
  String? selectedState;
  String? selectedMissingItems;
  bool scanBeforeReturning = false;
  int? _setIdLoaded;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int && _setIdLoaded == null) {
      _setIdLoaded = args;
      ref.read(setDetailProvider.notifier).load(args);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(setDetailProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF5CB58),
      body: AppBackground(
        title: 'Lego Set',
        onBack: () => Navigator.pop(context),
        onHome: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
          );
        },
        child: SafeArea(
          child: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : state.errorMessage != null
              ? Center(
                  child: Text(
                    state.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : state.set == null
              ? const Center(child: Text('Nincs adat.'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // Placeholder kép
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Text(
                            'Set',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Title
                      const Text(
                        'Title',
                        style: TextStyle(
                          color: Color(0xFF391713),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Location
                      const Text(
                        'Location',
                        style: TextStyle(
                          color: Color(0xFF252525),
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Owner
                      const Text(
                        'Owner',
                        style: TextStyle(
                          color: Color(0xFF252525),
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Rental Price
                      const Text(
                        'Rental Price',
                        style: TextStyle(
                          color: Color(0xFF252525),
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Deposit
                      const Text(
                        'Deposit',
                        style: TextStyle(
                          color: Color(0xFF252525),
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Scan Before Returning checkbox
                      Row(
                        children: [
                          Checkbox(
                            value: scanBeforeReturning,
                            onChanged: (value) {
                              setState(() {
                                scanBeforeReturning = value ?? false;
                              });
                            },
                            activeColor: const Color(0xFF848383),
                          ),
                          const Text(
                            'Scan Before Returning',
                            style: TextStyle(
                              color: Color(0xFF252525),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Number of Items
                      const Text(
                        'Number of Items',
                        style: TextStyle(
                          color: Color(0xFF252525),
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // State dropdown
                      _DetailDropdown(
                        label: 'State',
                        value: selectedState,
                        onChanged: (value) {
                          setState(() {
                            selectedState = value;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // Missing Items dropdown
                      _DetailDropdown(
                        label: 'Missing Items',
                        value: selectedMissingItems,
                        onChanged: (value) {
                          setState(() {
                            selectedMissingItems = value;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // Notes
                      const Text(
                        'Notes',
                        style: TextStyle(
                          color: Color(0xFF252525),
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Availability Calendar placeholder
                      /* Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text('Calendar - következő lépés'),
                ),
              ), */
                      // Availability Calendar
                      const Text(
                        'Availability Calendar',
                        style: TextStyle(
                          color: Color(0xFF252525),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),

                      _AvailabilityCalendar(),

                      const SizedBox(height: 24),

                      // Total Price
                      const Text(
                        'Total Price:',
                        style: TextStyle(
                          color: Color(0xFF391713),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Rent button
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
                            // TODO: rent action
                          },
                          child: const Text(
                            'Rent',
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
bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0, // 0 = Search
          onTap: (index) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => MainScreen(initialIndex: index),
              ),
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

class _DetailDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final ValueChanged<String?> onChanged;

  const _DetailDropdown({
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
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[400]!),
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

class _AvailabilityCalendar extends StatefulWidget {
  @override
  State<_AvailabilityCalendar> createState() => _AvailabilityCalendarState();
}

class _AvailabilityCalendarState extends State<_AvailabilityCalendar> {
  int currentYear = 2026;
  int currentMonth = 2; // február
  DateTime? startDate;
  DateTime? endDate;

  void _previousMonth() {
    setState(() {
      if (currentMonth == 1) {
        currentMonth = 12;
        currentYear--;
      } else {
        currentMonth--;
      }
    });
  }

  void _nextMonth() {
    setState(() {
      if (currentMonth == 12) {
        currentMonth = 1;
        currentYear++;
      } else {
        currentMonth++;
      }
    });
  }

  void _previousYear() {
    setState(() {
      currentYear--;
    });
  }

  void _nextYear() {
    setState(() {
      currentYear++;
    });
  }

  void _selectDay(int day) {
    final selectedDate = DateTime(currentYear, currentMonth, day);

    setState(() {
      if (startDate == null || (startDate != null && endDate != null)) {
        // Első kijelölés vagy újrakezdés
        startDate = selectedDate;
        endDate = null;
      } else if (selectedDate.isBefore(startDate!)) {
        // Ha a második előbb van, csere
        endDate = startDate;
        startDate = selectedDate;
      } else {
        // Második kijelölés
        endDate = selectedDate;
      }
    });
  }

  bool _isDayInRange(int day) {
    if (startDate == null) return false;

    final dayDate = DateTime(currentYear, currentMonth, day);

    if (endDate == null) {
      return dayDate.isAtSameMomentAs(startDate!);
    }

    return (dayDate.isAtSameMomentAs(startDate!) ||
        dayDate.isAtSameMomentAs(endDate!) ||
        (dayDate.isAfter(startDate!) && dayDate.isBefore(endDate!)));
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
    final daysInMonth = _daysInMonth(currentYear, currentMonth);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          // Year selector
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _previousYear,
                icon: const Icon(Icons.chevron_left),
                color: const Color(0xFF391713),
              ),
              Text(
                '$currentYear',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              IconButton(
                onPressed: _nextYear,
                icon: const Icon(Icons.chevron_right),
                color: const Color(0xFF391713),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Month selector
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _previousMonth,
                icon: const Icon(Icons.chevron_left),
                color: const Color(0xFF391713),
              ),
              SizedBox(
                width: 120,
                child: Text(
                  _monthName(currentMonth),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                onPressed: _nextMonth,
                icon: const Icon(Icons.chevron_right),
                color: const Color(0xFF391713),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Weekday headers
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              Center(
                child: Text('M', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              Center(
                child: Text('T', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              Center(
                child: Text('W', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              Center(
                child: Text('T', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              Center(
                child: Text('F', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              Center(
                child: Text('S', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              Center(
                child: Text('S', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Days grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: daysInMonth,
            itemBuilder: (context, index) {
              final day = index + 1;
              final isInRange = _isDayInRange(day);

              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => _selectDay(day),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isInRange
                          ? const Color(0xFF848383)
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isInRange
                            ? const Color(0xFF848383)
                            : Colors.grey[300]!,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$day',
                        style: TextStyle(
                          color: isInRange ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SetDetailContent extends StatelessWidget {
  final LegoSet set;

  const _SetDetailContent({required this.set});

  @override
  Widget build(BuildContext context) {
    // ide jöhet a már meglévő naptár, foglalás gomb, stb.
    return Column(
      children: [
        Text(set.title),
        if (set.setNum != null) Text('Set #: ${set.setNum}'),
        if (set.location != null) Text('Helyszín: ${set.location}'),
        // ...
      ],
    );
  }
}
