import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lego_rental_frontend/core/services/api_service.dart';
import 'package:lego_rental_frontend/core/widgets/app_background.dart';
import 'package:lego_rental_frontend/features/home/home_screen.dart';
import 'package:lego_rental_frontend/features/scan/scan_providers.dart';
import 'package:lego_rental_frontend/features/rentals/rental_providers.dart';
import 'package:lego_rental_frontend/core/models/rental_model.dart';
import 'package:lego_rental_frontend/core/models/scan_models.dart';

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

  void _showManualIdentifySheet(List<ScanItemModel> items) {
    final first = items.first;
    final sheetTitle =
        '${first.partNum}${first.color != null ? ' • ${first.color}' : ''}';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manual identification',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF391713),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  sheetTitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF848383),
                  ),
                ),
                if (first.name != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    first.name!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF252525),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.55,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isMissing = item.isMissing;
                      final isAi = item.isIdentified;
                      final isManual = item.isManuallyConfirmed;

                      String statusLabel;
                      Color statusColor;
                      IconData statusIcon;

                      if (isManual) {
                        statusLabel = 'Manually confirmed';
                        statusColor = Colors.blue;
                        statusIcon = Icons.person;
                      } else if (isAi) {
                        statusLabel = 'AI identified';
                        statusColor = Colors.green;
                        statusIcon = Icons.check_circle;
                      } else {
                        statusLabel = 'Missing';
                        statusColor = Colors.orange;
                        statusIcon = Icons.help_outline;
                      }

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            Icon(statusIcon, color: statusColor, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Item #${item.id}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF391713),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    statusLabel,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: statusColor,
                                    ),
                                  ),
                                  if (item.confidence != null) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      'Confidence: ${(item.confidence! * 100).toStringAsFixed(0)}%',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF848383),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (isMissing)
                              OutlinedButton(
                                onPressed: () async {
                                  await ref
                                      .read(scanProvider.notifier)
                                      .manualConfirm(itemId: item.id);

                                  if (!mounted) return;

                                  Navigator.pop(context);

                                  ScaffoldMessenger.of(this.context)
                                      .showSnackBar(
                                    const SnackBar(
                                      content: Text('Item manually confirmed.'),
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF391713),
                                  side: BorderSide(color: Colors.grey[400]!),
                                ),
                                child: const Text('Confirm'),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
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

  Future<void> _startScanSession() async {
    if (_selectedRental == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rental.')),
      );
      return;
    }

    await ref.read(scanProvider.notifier).loadOrCreateSession(
          rentalId: _selectedRental!.id,
          legoSetId: _selectedRental!.legoSetId,
        );
  }

  Future<void> _resetProgress() async {
    await ref.read(scanProvider.notifier).resetProgress();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Scan progress reset.')),
    );
  }

  Future<void> _finishSession() async {
    await ref.read(scanProvider.notifier).finishSession();

    if (!mounted) return;

    final session = ref.read(scanProvider).session;
    if (session == null) return;

    final missing = session.missingCount;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          missing == 0
              ? 'Scan finished – all elements found.'
              : 'Scan finished – $missing elements still missing.',
        ),
        backgroundColor: missing == 0 ? Colors.green : Colors.orange,
      ),
    );

    ref.read(scanProvider.notifier).reset();
    setState(() => _selectedRental = null);
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Text(
        message,
        style: const TextStyle(color: Colors.red),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(scanProvider);
    final rentalsState = ref.watch(myRentalsProvider);
    final session = scanState.session;
    final welcomeImageUrl =
        '${ApiService.baseUrl}/proxy/image?url=${Uri.encodeComponent('https://cdn.amightygirl.com/catalog/product/cache/1/image/9df78eab33525d08d6e5fb8d27136e95/l/e/lego_volcano_scientist.jpg')}';

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
                if (scanState.errorMessage != null) ...[
                  _buildErrorBanner(scanState.errorMessage!),
                  const SizedBox(height: 12),
                ],
                if (session == null) ...[
                  const SizedBox(height: 16),

                  // ── Instructions ────────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
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
                        const SizedBox(width: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 100,
                            height: 100,
                            color: Colors.white,
                            child: Image.network(
                              welcomeImageUrl,
                              fit: BoxFit.contain,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  size: 28,
                                  color: Color(0xFF391713),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Rental selector ─────────────────────────────────────
                  const Text(
                    'Select Rental',
                    style: TextStyle(
                      color: Color(0xFF391713),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
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
                            hint: const Text(
                              'Select Rental',
                              style: TextStyle(
                                color: Color(0xFF848383),
                                fontSize: 14,
                              ),
                            ),
                            isExpanded: true,
                            underline: const SizedBox(),
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: Color(0xFF391713),
                            ),
                            items: rentalsState.rentals
                                .map(
                                  (r) => DropdownMenuItem<RentalModel>(
                                    value: r,
                                    child: Text(
                                      '#${r.id} – ${r.startDate.toString().substring(0, 10)} → ${r.endDate.toString().substring(0, 10)}',
                                      style: const TextStyle(
                                        color: Color(0xFF391713),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() => _selectedRental = value);
                            },
                          ),
                  ),
                  const SizedBox(height: 16),

                  // ── Start button ────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(
                        Icons.play_arrow,
                        color: Color(0xFF391713),
                      ),
                      label: const Text(
                        'Start scan',
                        style: TextStyle(
                          color: Color(0xFF391713),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD3D3D3),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      onPressed: scanState.isLoading ? null : _startScanSession,
                    ),
                  ),
                ],
                if (session != null) ...[
                  // ── Status bar ──────────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: session.status == 'COMPLETE'
                          ? Colors.green[50]
                          : Colors.grey[200],
                      border: Border.all(
                        color: session.status == 'COMPLETE'
                            ? Colors.green
                            : Colors.grey[400]!,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          session.status == 'COMPLETE'
                              ? Icons.check_circle
                              : Icons.pending,
                          color: session.status == 'COMPLETE'
                              ? Colors.green
                              : Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${session.status} | ${session.identifiedCount}/${session.totalCount} identified',
                            style: TextStyle(
                              color: session.status == 'COMPLETE'
                                  ? Colors.green[800]
                                  : const Color(0xFF391713),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Progress ────────────────────────────────────────────
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
                    '${session.identifiedCount} / ${session.totalCount} | ${session.missingCount} missing',
                    style: const TextStyle(
                      color: Color(0xFF848383),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Scan button ─────────────────────────────────────────
                  Center(
                    child: SizedBox(
                      width: 220,
                      child: ElevatedButton.icon(
                        icon: const Icon(
                          Icons.camera_alt,
                          color: Color(0xFF391713),
                        ),
                        label: const Text(
                          'Scan elements',
                          style: TextStyle(
                            color: Color(0xFF391713),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: session.status == 'COMPLETE'
                              ? Colors.grey[300]
                              : const Color(0xFFD3D3D3),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                        onPressed:
                            scanState.isLoading || session.status == 'COMPLETE'
                                ? null
                                : _showSourceDialog,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Main actions ────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF391713),
                            side: BorderSide(color: Colors.grey[400]!),
                            backgroundColor: Colors.grey[100],
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                          ),
                          onPressed: scanState.isLoading ||
                                  session.status == 'COMPLETE'
                              ? null
                              : _resetProgress,
                          child: const Text('Reset progress'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF391713),
                            side: BorderSide(color: Colors.grey[400]!),
                            backgroundColor: Colors.grey[100],
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                          ),
                          onPressed: scanState.isLoading ||
                                  session.status == 'COMPLETE'
                              ? null
                              : _finishSession,
                          child: const Text('Finish scan'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── Elements list ───────────────────────────────────────
                  const Text(
                    'Elements',
                    style: TextStyle(
                      color: Color(0xFF391713),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 540,
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
                        final partiallyDone =
                            identifiedCount > 0 && identifiedCount < total;

                        final firstName = items.first.name;
                        final partNum = items.first.partNum;
                        final color = items.first.color;
                        final itemColor = items.first.color;

                        final imgUrl = items.first.imgUrl != null
                            ? '${ApiService.baseUrl}/proxy/image?url=${Uri.encodeComponent(items.first.imgUrl!)}'
                            : null;

                        final isLastIdentified =
                            scanState.lastResults.isNotEmpty &&
                                items.any((i) => i.identified) &&
                                scanState.lastResults.any(
                                  (r) =>
                                      r.partNum == partNum &&
                                      (r.colorName == null ||
                                          r.colorName == itemColor),
                                );

                        final borderColor = allDone
                            ? Colors.green
                            : partiallyDone
                                ? Colors.orange
                                : Colors.grey[300]!;

                        final tileColor = isLastIdentified
                            ? const Color(0xFFFFF8E1)
                            : Colors.white;

                        return InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => _showManualIdentifySheet(items),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: tileColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: borderColor,
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
                                      loadingBuilder: (
                                        context,
                                        child,
                                        loadingProgress,
                                      ) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        );
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                        Icons.broken_image,
                                        size: 48,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                Icon(
                                  allDone
                                      ? Icons.check_circle
                                      : partiallyDone
                                          ? Icons.radio_button_checked
                                          : Icons.radio_button_unchecked,
                                  color: allDone
                                      ? Colors.green
                                      : partiallyDone
                                          ? Colors.orange
                                          : Colors.grey,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        partNum,
                                        style: const TextStyle(
                                          color: Color(0xFF391713),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (firstName != null)
                                        Text(
                                          firstName,
                                          style: const TextStyle(
                                            color: Color(0xFF252525),
                                            fontSize: 11,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      if (color != null)
                                        Text(
                                          color,
                                          style: const TextStyle(
                                            color: Color(0xFF848383),
                                            fontSize: 11,
                                          ),
                                        ),
                                      if (isLastIdentified)
                                        Builder(
                                          builder: (context) {
                                            final match = scanState.lastResults
                                                .where(
                                                    (r) => r.partNum == partNum)
                                                .toList();

                                            if (match.isEmpty) {
                                              return const SizedBox();
                                            }

                                            final best = match.reduce(
                                              (a, b) =>
                                                  a.confidence > b.confidence
                                                      ? a
                                                      : b,
                                            );

                                            return Text(
                                              'Confidence: ${(best.confidence * 100).toStringAsFixed(0)}%',
                                              style: const TextStyle(
                                                color: Color(0xFF391713),
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            );
                                          },
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '$identifiedCount/$total',
                                      style: TextStyle(
                                        color: allDone
                                            ? Colors.green
                                            : partiallyDone
                                                ? Colors.orange[800]
                                                : const Color(0xFF391713),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Icon(
                                      Icons.chevron_right,
                                      size: 18,
                                      color: Color(0xFF848383),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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

  const _InstructionRow({
    required this.icon,
    required this.text,
  });

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
