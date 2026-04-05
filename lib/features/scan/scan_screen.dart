import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lego_rental_frontend/core/services/api_service.dart';
import 'package:lego_rental_frontend/core/widgets/app_background.dart';
import 'package:lego_rental_frontend/features/home/home_screen.dart';
import 'package:lego_rental_frontend/features/scan/scan_providers.dart';
import 'package:lego_rental_frontend/features/rentals/rental_providers.dart';
import 'package:lego_rental_frontend/core/models/rental_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  final ImagePicker _picker = ImagePicker();
  RentalModel? _selectedRental;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(myRentalsProvider.notifier).load());
  }

  Future<void> _pickAndScan({required ImageSource source}) async {
    final scanState = ref.read(scanProvider);
    if (scanState.session == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('First start a scan session.')),
      );
      return;
    }

    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (image == null) return;

    final bytes = await image.readAsBytes();
    await ref.read(scanProvider.notifier).identifyAndMark(
          imageBytes: bytes,
          fileName: image.name,
        );
  }

  void _showSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF391713)),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickAndScan(source: ImageSource.camera);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.photo_library, color: Color(0xFF391713)),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickAndScan(source: ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(scanProvider);
    final rentalsState = ref.watch(myRentalsProvider);
    final session = scanState.session;

    return Scaffold(
      backgroundColor: const Color(0xFFF5CB58),
      body: AppBackground(
        title: 'Element Scanner',
        onBack: () => Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        ),
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

                // ── Instrukciók (csak session előtt) ─────────────────────
                if (session == null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Before scanning:',
                          style: TextStyle(
                            color: Color(0xFF391713),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 10),
                        _InstructionRow(
                          icon: Icons.wb_sunny_outlined,
                          text:
                              'Photograph in bright light, preferably on a white or plain background.',
                        ),
                        SizedBox(height: 8),
                        _InstructionRow(
                          icon: Icons.layers_outlined,
                          text: 'You can scan multiple elements at once.',
                        ),
                        SizedBox(height: 8),
                        _InstructionRow(
                          icon: Icons.space_bar,
                          text:
                              'Elements must not overlap or touch each other.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Rental választó ───────────────────────────────────────
                const Text('Select Rental',
                    style: TextStyle(
                        color: Color(0xFF391713),
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: rentalsState.isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : DropdownButton<RentalModel>(
                          value: _selectedRental,
                          hint: const Text('Select Rental',
                              style: TextStyle(
                                  color: Color(0xFF848383), fontSize: 14)),
                          isExpanded: true,
                          underline: const SizedBox(),
                          icon: const Icon(Icons.arrow_drop_down,
                              color: Color(0xFF391713)),
                          items: rentalsState.rentals
                              .map((r) => DropdownMenuItem<RentalModel>(
                                    value: r,
                                    child: Text(
                                      '#${r.id} – ${r.startDate.toString().substring(0, 10)} → ${r.endDate.toString().substring(0, 10)}',
                                      style: const TextStyle(
                                          color: Color(0xFF391713),
                                          fontSize: 13),
                                    ),
                                  ))
                              .toList(),
                          onChanged: session != null
                              ? null // session közben ne lehessen váltani
                              : (value) => setState(() {
                                    _selectedRental = value;
                                  }),
                        ),
                ),
                const SizedBox(height: 16),

                // ── Session indítás gomb ──────────────────────────────────
                if (session == null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.play_arrow,
                          color: Color(0xFF391713)),
                      label: const Text('Start Scan Session',
                          style: TextStyle(
                              color: Color(0xFF391713),
                              fontSize: 15,
                              fontWeight: FontWeight.w500)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD3D3D3),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13)),
                      ),
                      onPressed: scanState.isLoading
                          ? null
                          : () {
                              if (_selectedRental == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Please select a rental.')));
                                return;
                              }
                              ref.read(scanProvider.notifier).createSession(
                                    rentalId: _selectedRental!.id,
                                    legoSetId: _selectedRental!.legoSetId,
                                  );
                            },
                    ),
                  ),

                // ── Aktív session UI ──────────────────────────────────────
                if (session != null) ...[
                  // Státusz sáv
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: session.status == 'COMPLETE'
                          ? Colors.green[50]
                          : Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: session.status == 'COMPLETE'
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          session.status == 'COMPLETE'
                              ? Icons.check_circle
                              : Icons.pending,
                          color: session.status == 'COMPLETE'
                              ? Colors.green
                              : Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${session.status} | '
                          '${session.identifiedCount}/${session.totalCount} identified',
                          style: TextStyle(
                            color: session.status == 'COMPLETE'
                                ? Colors.green[800]
                                : Colors.orange[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Progress bar
                  LinearProgressIndicator(
                    value: session.totalCount > 0
                        ? session.identifiedCount / session.totalCount
                        : 0,
                    backgroundColor: Colors.grey[300],
                    color: Colors.green,
                    minHeight: 6,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${session.identifiedCount} / ${session.totalCount} | '
                    '${session.missingCount} missing',
                    style:
                        const TextStyle(color: Color(0xFF848383), fontSize: 12),
                  ),
                  const SizedBox(height: 16),

                  // ── Utolsó azonosított elem a listában kiemelve ──────────
                  // (a "last identified" banner helyett a listában látszik)

                  // Scan gomb
                  Center(
                    child: SizedBox(
                      width: 200,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.camera_alt,
                            color: Color(0xFF391713)),
                        label: const Text('Scan Elements',
                            style: TextStyle(
                                color: Color(0xFF391713),
                                fontSize: 16,
                                fontWeight: FontWeight.w500)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD3D3D3),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13)),
                        ),
                        onPressed:
                            scanState.isLoading ? null : _showSourceDialog,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Cancel / Save gombok
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF391713),
                            side: BorderSide(color: Colors.grey[400]!),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13)),
                          ),
                          onPressed: () {
                            ref.read(scanProvider.notifier).reset();
                            setState(() => _selectedRental = null);
                          },
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: session.status == 'COMPLETE'
                                ? const Color(0xFFFFC107)
                                : const Color(0xFFD3D3D3),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13)),
                          ),
                          onPressed: () {
                            final missing = session.missingCount;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(missing == 0
                                    ? 'Scan complete – all elements found!'
                                    : 'Scan saved – $missing elements still missing.'),
                                backgroundColor:
                                    missing == 0 ? Colors.green : Colors.orange,
                              ),
                            );
                            ref.read(scanProvider.notifier).reset();
                            setState(() => _selectedRental = null);
                          },
                          child: const Text('Save',
                              style: TextStyle(
                                  color: Color(0xFF391713),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Hiba
                  if (scanState.errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Text(scanState.errorMessage!,
                          style: const TextStyle(color: Colors.red)),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // ── Elemek listája ────────────────────────────────────────
                  const Text('Elements',
                      style: TextStyle(
                          color: Color(0xFF391713),
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Container(
                    height: 400,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: ListView(
                      padding: const EdgeInsets.all(8),
                      children: session.itemsByPartNum.entries.map((entry) {
                        final items = entry.value;
                        final identifiedCount =
                            items.where((i) => i.identified).length;
                        final total = items.length;
                        final allDone = identifiedCount == total;
                        final firstName = items.first.name;
                        final partNum = items.first.partNum;
                        final color = items.first.color;
                        final imgUrl = items.first.imgUrl != null
                            ? '${ApiService.baseUrl}/proxy/image?url=${Uri.encodeComponent(items.first.imgUrl!)}'
                            : null;
                        // Utolsó azonosított elem kiemelése
                        final isLastIdentified =
                            scanState.lastResult?.partNum == partNum;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: isLastIdentified
                                ? const Color(0xFFFFF3CD)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isLastIdentified
                                  ? const Color(0xFFFFE082)
                                  : allDone
                                      ? Colors.green
                                      : identifiedCount > 0
                                          ? Colors.orange
                                          : Colors.grey[300]!,
                              width: isLastIdentified ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              if (imgUrl != null)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Image.network(
                                    imgUrl,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.contain,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      );
                                    },
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(Icons.broken_image,
                                                size: 48, color: Colors.grey),
                                  ),
                                ),
                              Icon(
                                allDone
                                    ? Icons.check_circle
                                    : identifiedCount > 0
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_unchecked,
                                color: allDone
                                    ? Colors.green
                                    : identifiedCount > 0
                                        ? Colors.orange
                                        : Colors.grey,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      partNum,
                                      style: const TextStyle(
                                          color: Color(0xFF391713),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    if (firstName != null)
                                      Text(
                                        firstName,
                                        style: const TextStyle(
                                            color: Color(0xFF252525),
                                            fontSize: 11),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    if (color != null)
                                      Text(
                                        color,
                                        style: const TextStyle(
                                            color: Color(0xFF848383),
                                            fontSize: 11),
                                      ),
                                    // Utolsó azonosítottnál confidence
                                    if (isLastIdentified &&
                                        scanState.lastResult != null)
                                      Text(
                                        'Confidence: ${(scanState.lastResult!.confidence * 100).toStringAsFixed(0)}%',
                                        style: const TextStyle(
                                          color: Color(0xFF391713),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Text(
                                '$identifiedCount/$total',
                                style: TextStyle(
                                  color: allDone
                                      ? Colors.green
                                      : Colors.orange[800],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],

                if (scanState.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
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

// ── Segédwidget az instrukció sorhoz ─────────────────────────────────────────
class _InstructionRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InstructionRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF391713)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF252525),
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
