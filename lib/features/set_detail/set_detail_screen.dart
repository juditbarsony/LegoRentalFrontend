import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lego_rental_frontend/core/models/availability_model.dart';
import 'package:lego_rental_frontend/core/services/api_service.dart';
import 'package:lego_rental_frontend/core/widgets/app_background.dart';
import 'package:lego_rental_frontend/features/home/home_screen.dart';
import 'package:lego_rental_frontend/features/main/main_screen.dart';
import 'package:lego_rental_frontend/features/rentals/rental_screen.dart';
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
  final bool _scanBeforeReturning = false;
  DateTime? _rentalStart;
  DateTime? _rentalEnd;

  @override
  Widget build(BuildContext context) {
    final s = widget.set;

    String _fakeRating(dynamic seed) {
      final base = seed.toString().codeUnits.fold(0, (sum, c) => sum + c);
      final value = 2.0 + (base % 31) / 10.0; // 2.0 - 5.0
      return value.toStringAsFixed(1);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

// ── Preview kártya: kép + fő adatok ──────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[300]!),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 110,
                    height: 110,
                    color: Colors.grey[200],
                    child: s.imgUrl != null
                        ? Image.network(
                            '${ApiService.baseUrl}/proxy/image?url=${Uri.encodeComponent(s.imgUrl!)}',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _imagePlaceholder(),
                          )
                        : _imagePlaceholder(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              s.title,
                              style: const TextStyle(
                                color: Color(0xFF391713),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: s.visibility == 'friends_only'
                                  ? const Color(0xFFFFF3CD)
                                  : const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: s.visibility == 'friends_only'
                                    ? const Color(0xFFFFE082)
                                    : const Color(0xFFA5D6A7),
                              ),
                            ),
                            child: Text(
                              s.visibility == 'friends_only'
                                  ? 'Friends only'
                                  : (s.public ? 'Public' : 'Private'),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: s.visibility == 'friends_only'
                                    ? const Color(0xFF856404)
                                    : const Color(0xFF2E7D32),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      if (s.setNum.isNotEmpty)
                        Text(
                          'Set: ${s.setNum}',
                          style: const TextStyle(
                            color: Color(0xFF848383),
                            fontSize: 13,
                          ),
                        ),
                      const SizedBox(height: 6),
                      Text(
                        s.location,
                        style: const TextStyle(
                          color: Color(0xFF252525),
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${s.rentalPrice.toStringAsFixed(0)} Ft / day',
                        style: const TextStyle(
                          color: Color(0xFF252525),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                SizedBox(
                  width: (MediaQuery.of(context).size.width - 72) / 2,
                  child: _infoTile('Location', s.location),
                ),
                SizedBox(
                  width: (MediaQuery.of(context).size.width - 72) / 2,
                  child: _infoTile(
                    'Rental price',
                    '${s.rentalPrice.toStringAsFixed(0)} Ft / day',
                  ),
                ),
                SizedBox(
                  width: (MediaQuery.of(context).size.width - 72) / 2,
                  child: _infoTile(
                      'Deposit', '${s.deposit.toStringAsFixed(0)} Ft'),
                ),
                if (s.numberOfItems != null)
                  SizedBox(
                    width: (MediaQuery.of(context).size.width - 72) / 2,
                    child: _infoTile('Number of items', '${s.numberOfItems}'),
                  ),
                if (s.state != null && s.state!.isNotEmpty)
                  SizedBox(
                    width: (MediaQuery.of(context).size.width - 72) / 2,
                    child: _infoTile('State', s.state!),
                  ),
                SizedBox(
                  width: (MediaQuery.of(context).size.width - 72) / 2,
                  child: _infoTile(
                    'Scanning before return',
                    s.scanRequired ? 'Yes' : 'No',
                  ),
                ),
                SizedBox(
                  width: (MediaQuery.of(context).size.width - 72) / 2,
                  child: _infoTile(
                    'Visibility',
                    s.visibility == 'friends_only'
                        ? 'Friends only'
                        : (s.public ? 'Public' : 'Private'),
                  ),
                ),
                if (s.ownerName != null && s.ownerName!.isNotEmpty)
                  SizedBox(
                    width: (MediaQuery.of(context).size.width - 72) / 2,
                    child: _infoTile('Owner', s.ownerName!),
                  ),
                SizedBox(
                  width: (MediaQuery.of(context).size.width - 72) / 2,
                  child: _infoTile(
                    'Rating',
                    s.averageRating != null
                        ? '${s.averageRating!.toStringAsFixed(1)} / 5'
                            '${s.reviewCount != null ? ' (${s.reviewCount})' : ''}'
                        : '${_fakeRating(s.id)} / 5',
                  ),
                ),
                if (s.averageRating != null)
                  SizedBox(
                    width: (MediaQuery.of(context).size.width - 72) / 2,
                    child: _infoTile(
                      'Rating',
                      '${s.averageRating!.toStringAsFixed(1)} / 5'
                          '${s.reviewCount != null ? ' (${s.reviewCount})' : ''}',
                    ),
                  ),
              ],
            ),
          ),

          if (s.averageRating != null || s.reviewCount != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Row(
                    children: List.generate(5, (index) {
                      final filled = index < (s.averageRating ?? 0).round();
                      return Icon(
                        filled ? Icons.star : Icons.star_border,
                        size: 18,
                        color: const Color(0xFFFFC107),
                      );
                    }),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    s.averageRating != null
                        ? '${s.averageRating!.toStringAsFixed(1)} / 5'
                        : 'No rating yet',
                    style: const TextStyle(
                      color: Color(0xFF252525),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (s.reviewCount != null)
                    Text(
                      '(${s.reviewCount} reviews)',
                      style: const TextStyle(
                        color: Color(0xFF848383),
                        fontSize: 13,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 8),

          //--Elérhetőség-----------------------------------------------------
          const Text(
            'Available periods',
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
                padding: const EdgeInsets.symmetric(vertical: 12),
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

  Widget _infoTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF848383),
              fontWeight: FontWeight.w500,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF252525),
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
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
  const AvailabilityCalendar({super.key, this.onRangeSelected});

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
      padding: const EdgeInsets.all(12),
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
          const SizedBox(height: 2),

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
          const SizedBox(height: 2),

          // ── Hétköznapok fejléc ───────────────────────────────────────
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 7,
            mainAxisSpacing: 3,
            crossAxisSpacing: 3,
            childAspectRatio: 1.2,
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
          const SizedBox(height: 2),

          // ── Napok rács ───────────────────────────────────────────────
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 3,
              crossAxisSpacing: 3,
              childAspectRatio: 1.08,
            ),
            itemCount: daysInMonth + firstWeekday - 1,
            itemBuilder: (context, index) {
              // Üres cellák a hónap első napja előtt
              if (index < firstWeekday - 1) return const SizedBox();

              final day = index - firstWeekday + 2;
              final isInRange = _isDayInRange(day);
              final isStart = startDate != null &&
                  DateTime(currentYear, currentMonth, day) == startDate;
              final isEnd = endDate != null &&
                  DateTime(currentYear, currentMonth, day) == endDate;

              return GestureDetector(
                onTap: () => _selectDay(day),
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        isInRange ? const Color(0xFF848383) : Colors.grey[200],
                    borderRadius: BorderRadius.circular(6),
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
