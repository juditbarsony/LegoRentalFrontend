import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lego_rental_frontend/core/models/availability_model.dart';
import 'package:lego_rental_frontend/core/services/api_service.dart';
import 'package:lego_rental_frontend/core/widgets/app_background.dart';
import 'package:lego_rental_frontend/features/home/home_screen.dart';
import 'package:lego_rental_frontend/features/main/main_screen.dart';
import 'package:lego_rental_frontend/features/rental/rental_screen.dart';
import 'package:lego_rental_frontend/features/set_detail/set_detail_providers.dart';
import 'package:lego_rental_frontend/core/models/lego_set_model.dart';

class SetDetailScreen extends ConsumerStatefulWidget {
  final int setId;
  const SetDetailScreen({super.key, required this.setId});

  @override
  ConsumerState<SetDetailScreen> createState() => _SetDetailScreenState();
}

class _SetDetailScreenState extends ConsumerState<SetDetailScreen> {
  int? _setIdLoaded;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(setDetailProvider.notifier).load(widget.setId),
    );
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
              : SetDetailContent(
                  set: state.set!,
                  availabilities: state.availabilities,
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

// ─── SetDetailContent ────────────────────────────────────────────────────────

class SetDetailContent extends StatefulWidget {
  final LegoSetModel set;
  final List<AvailabilityModel> availabilities;

  const SetDetailContent({
    super.key,
    required this.set,
    required this.availabilities,
  });

  @override
  State<SetDetailContent> createState() => _SetDetailContentState();
}

class _SetDetailContentState extends State<SetDetailContent> {
  bool _scanBeforeReturning = false;
  DateTime? _rentalStart;
  DateTime? _rentalEnd;

  @override
  Widget build(BuildContext context) {
    final s = widget.set;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // ── Kép ──────────────────────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: s.imgUrl != null
                ? Image.network(
                    '${ApiService.baseUrl}/proxy/image?url=${Uri.encodeComponent(s.imgUrl!)}',
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => _imagePlaceholder(),
                  )
                : _imagePlaceholder(),
          ),
          const SizedBox(height: 24),

          // ── Cím ──────────────────────────────────────────────────────────
          const Text(
            'Title',
            style: TextStyle(
              color: Color(0xFF391713),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            s.title,
            style: const TextStyle(color: Color(0xFF252525), fontSize: 16),
          ),
          const SizedBox(height: 8),

          // ── Set szám ─────────────────────────────────────────────────────
          if (s.setNum.isNotEmpty) ...[
            Text(
              'Set: ${s.setNum}',
              style: const TextStyle(color: Color(0xFF848383), fontSize: 13),
            ),
            const SizedBox(height: 8),
          ],

          // ── Helyszín ─────────────────────────────────────────────────────
          const Text(
            'Location',
            style: TextStyle(
              color: Color(0xFF391713),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            s.location,
            style: const TextStyle(color: Color(0xFF252525), fontSize: 14),
          ),
          const SizedBox(height: 16),

          // ── Bérleti díj ──────────────────────────────────────────────────
          const Text(
            'Rental Price',
            style: TextStyle(
              color: Color(0xFF391713),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${s.rentalPrice.toStringAsFixed(0)} Ft / day',
            style: const TextStyle(color: Color(0xFF252525), fontSize: 14),
          ),
          const SizedBox(height: 8),

          // ── Kaució ───────────────────────────────────────────────────────
          const Text(
            'Deposit',
            style: TextStyle(
              color: Color(0xFF391713),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${s.deposit.toStringAsFixed(0)} Ft',
            style: const TextStyle(color: Color(0xFF252525), fontSize: 14),
          ),
          const SizedBox(height: 16),

          // ── Elemek száma ─────────────────────────────────────────────────
          if (s.numberOfItems != null) ...[
            const Text(
              'Number of Items',
              style: TextStyle(
                color: Color(0xFF391713),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${s.numberOfItems} db',
              style: const TextStyle(color: Color(0xFF252525), fontSize: 14),
            ),
            const SizedBox(height: 16),
          ],

          // ── Állapot ──────────────────────────────────────────────────────
          if (s.state != null) ...[
            const Text(
              'State',
              style: TextStyle(
                color: Color(0xFF391713),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              s.state!,
              style: const TextStyle(color: Color(0xFF252525), fontSize: 14),
            ),
            const SizedBox(height: 16),
          ],

          // ── Megjegyzés ───────────────────────────────────────────────────
          if (s.notes != null &&
              s.notes!.isNotEmpty &&
              s.notes != 'string') ...[
            const Text(
              'Notes',
              style: TextStyle(
                color: Color(0xFF391713),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              s.notes!,
              style: const TextStyle(color: Color(0xFF252525), fontSize: 14),
            ),
            const SizedBox(height: 16),
          ],

          // ── Scan checkbox ────────────────────────────────────────────────
          Row(
            children: const [
              Icon(Icons.qr_code_scanner, size: 18, color: Color(0xFF848383)),
              SizedBox(width: 8),
              Text(
                'Scanning needed before return',
                style: TextStyle(color: Color(0xFF252525), fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 16),

          //--Elérhetőség-----------------------------------------------------
          const Text(
            'Elérhető időszakok',
            style: TextStyle(
              color: Color(0xFF391713),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          widget.availabilities.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: const Text(
                    'Nincs megadott elérhető időszak.',
                    style: TextStyle(color: Color(0xFF848383), fontSize: 13),
                  ),
                )
              : Column(
                  children: widget.availabilities.map((a) {
                    final start =
                        '${a.startDate.year}.${a.startDate.month.toString().padLeft(2, '0')}.${a.startDate.day.toString().padLeft(2, '0')}';
                    final end =
                        '${a.endDate.year}.${a.endDate.month.toString().padLeft(2, '0')}.${a.endDate.day.toString().padLeft(2, '0')}';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Color(0xFF391713),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '$start  →  $end',
                            style: const TextStyle(
                              color: Color(0xFF252525),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
          const SizedBox(height: 16),

          // ── Naptár ───────────────────────────────────────────────────────
          /*           const Text(
            'Availability Calendar',
            style: TextStyle(
              color: Color(0xFF252525),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          const AvailabilityCalendar(),
          const SizedBox(height: 24),
 */
          AvailabilityCalendar(
            onRangeSelected: (start, end) {
              setState(() {
                _rentalStart = start;
                _rentalEnd = end;
              });
            },
          ),
          // ── Bérlés gomb ──────────────────────────────────────────────────
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
                if (_rentalStart == null || _rentalEnd == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Kérlek válassz bérlési időszakot a naptárban!',
                      ),
                    ),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RentalScreen(
                      set: widget.set,
                      startDate: _rentalStart!,
                      endDate: _rentalEnd!,
                    ),
                  ),
                );
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
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Text('Set', style: TextStyle(fontSize: 18, color: Colors.grey)),
      ),
    );
  }
}

// ─── DetailDropdown ──────────────────────────────────────────────────────────

class DetailDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final ValueChanged<String?> onChanged;

  const DetailDropdown({
    super.key,
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
        items: const [],
        onChanged: onChanged,
      ),
    );
  }
}

// ─── AvailabilityCalendar ────────────────────────────────────────────────────

class AvailabilityCalendar extends StatefulWidget {
  final void Function(DateTime? start, DateTime? end)? onRangeSelected;
  const AvailabilityCalendar({this.onRangeSelected});

  @override
  State<AvailabilityCalendar> createState() => _AvailabilityCalendarState();
}

class _AvailabilityCalendarState extends State<AvailabilityCalendar> {
  int currentYear = 2026;
  int currentMonth = DateTime.now().month;
  DateTime? startDate;
  DateTime? endDate;

  void _previousMonth() => setState(() {
    if (currentMonth == 1) {
      currentMonth = 12;
      currentYear--;
    } else {
      currentMonth--;
    }
  });

  void _nextMonth() => setState(() {
    if (currentMonth == 12) {
      currentMonth = 1;
      currentYear++;
    } else {
      currentMonth++;
    }
  });

  void _previousYear() => setState(() => currentYear--);
  void _nextYear() => setState(() => currentYear++);

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
    widget.onRangeSelected?.call(startDate, endDate);
  }

  bool _isDayInRange(int day) {
    if (startDate == null) return false;
    final d = DateTime(currentYear, currentMonth, day);
    if (endDate == null) return d == startDate;
    return (d.isAtSameMomentAs(startDate!) ||
        d.isAtSameMomentAs(endDate!) ||
        (d.isAfter(startDate!) && d.isBefore(endDate!)));
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
    final daysInMonth = _daysInMonth(currentYear, currentMonth);
    final firstWeekday = DateTime(
      currentYear,
      currentMonth,
      1,
    ).weekday; // 1=hétfő

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          // ── Év választó ──────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _previousYear,
                icon: const Icon(Icons.chevron_left, color: Color(0xFF391713)),
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
                icon: const Icon(Icons.chevron_right, color: Color(0xFF391713)),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ── Hónap választó ───────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _previousMonth,
                icon: const Icon(Icons.chevron_left, color: Color(0xFF391713)),
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
                icon: const Icon(Icons.chevron_right, color: Color(0xFF391713)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Hétköznapok fejléc ───────────────────────────────────────
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              Center(
                child: Text('H', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              Center(
                child: Text('K', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              Center(
                child: Text(
                  'Sze',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Center(
                child: Text(
                  'Cs',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Center(
                child: Text('P', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              Center(
                child: Text(
                  'Szo',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Center(
                child: Text('V', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ── Napok rács ───────────────────────────────────────────────
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: daysInMonth + firstWeekday - 1,
            itemBuilder: (context, index) {
              // Üres cellák a hónap első napja előtt
              if (index < firstWeekday - 1) return const SizedBox();

              final day = index - firstWeekday + 2;
              final isInRange = _isDayInRange(day);
              final isStart =
                  startDate != null &&
                  DateTime(currentYear, currentMonth, day) == startDate;
              final isEnd =
                  endDate != null &&
                  DateTime(currentYear, currentMonth, day) == endDate;

              return GestureDetector(
                onTap: () => _selectDay(day),
                child: Container(
                  decoration: BoxDecoration(
                    color: isInRange
                        ? const Color(0xFF848383)
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isStart || isEnd
                          ? const Color(0xFF391713)
                          : isInRange
                          ? const Color(0xFF848383)
                          : Colors.grey[300]!,
                      width: isStart || isEnd ? 2 : 1,
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
              );
            },
          ),

          // ── Kiválasztott időszak megjelenítése ───────────────────────
          if (startDate != null) ...[
            const SizedBox(height: 16),
            Text(
              endDate != null
                  ? '${startDate!.year}.${startDate!.month.toString().padLeft(2, '0')}.${startDate!.day.toString().padLeft(2, '0')}'
                        ' – '
                        '${endDate!.year}.${endDate!.month.toString().padLeft(2, '0')}.${endDate!.day.toString().padLeft(2, '0')}'
                  : 'Kezdő dátum: ${startDate!.year}.${startDate!.month.toString().padLeft(2, '0')}.${startDate!.day.toString().padLeft(2, '0')}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF391713),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
