import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lego_rental_frontend/core/models/lego_set_model.dart';
import 'package:lego_rental_frontend/core/widgets/app_background.dart';
import 'package:lego_rental_frontend/core/widgets/app_primary_button.dart';
import 'package:lego_rental_frontend/core/widgets/app_secondary_button.dart';
import 'package:lego_rental_frontend/features/rentals/rental_providers.dart';

class RentalScreen extends ConsumerWidget {
  final LegoSetModel set;
  final DateTime startDate;
  final DateTime endDate;

  const RentalScreen({
    super.key,
    required this.set,
    required this.startDate,
    required this.endDate,
  });

  String _formatDate(DateTime d) =>
      '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';

  int get _days => endDate.difference(startDate).inDays + 1;
  double get _totalPrice => (set.rentalPrice * _days) + set.deposit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createRentalProvider);

    // Siker esetén visszanavigálás
    ref.listen(createRentalProvider, (_, next) {
      if (next.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rental !'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
        ref.read(createRentalProvider.notifier).reset();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5CB58),
      body: AppBackground(
        title: 'Confirm Rental',
        onBack: () => Navigator.pop(context),
        onHome: null,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // ── Set neve ─────────────────────────────────────────
                const Text(
                  'Set',
                  style: TextStyle(
                    color: Color(0xFF391713),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  set.title,
                  style: const TextStyle(
                    color: Color(0xFF252525),
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 16),

                // ── Összefoglaló kártya ───────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    children: [
                      _summaryRow('Start date', _formatDate(startDate)),
                      const Divider(),
                      _summaryRow('End date', _formatDate(endDate)),
                      const Divider(),
                      _summaryRow('Number of days', '$_days days'),
                      const Divider(),
                      _summaryRow(
                        'Rental price / day',
                        '${set.rentalPrice.toStringAsFixed(0)} Ft',
                      ),
                      const Divider(),
                      _summaryRow(
                        'Deposit',
                        '${set.deposit.toStringAsFixed(0)} Ft',
                      ),
                      const Divider(),
                      _summaryRow(
                        'Total (rental + deposit)',
                        '${_totalPrice.toStringAsFixed(0)} Ft',
                        bold: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // ── Kaució megjegyzés ────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3CD),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFFE082)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Color(0xFF856404),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'The deposit (${set.deposit.toStringAsFixed(0)} Ft) will be refunded upon return of the set.',
                          style: const TextStyle(
                            color: Color(0xFF856404),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Hiba ────────────────────────────────────────────
                if (state.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Text(
                      state.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Confirm gomb ────────────────────────────────────
                AppPrimaryButton(
                  label: 'Confirm Rental',
                  isLoading: state.isLoading,
                  onPressed: () {
                    ref.read(createRentalProvider.notifier).createRental(
                          legoSetId: set.id,
                          startDate: startDate,
                          endDate: endDate,
                        );
                  },
                ),
                const SizedBox(height: 16),
                AppSecondaryButton(
                  label: 'Cancel',
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: const Color(0xFF252525),
              fontSize: 14,
              fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: const Color(0xFF391713),
              fontSize: 14,
              fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
