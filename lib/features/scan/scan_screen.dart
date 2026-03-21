import 'package:flutter/material.dart';
import 'package:lego_rental_frontend/core/widgets/app_background.dart';
//import 'package:lego_rental_frontend/features/main/main_screen.dart';
import 'package:lego_rental_frontend/features/home/home_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  String? _selectedSet;
  final TextEditingController _identifiedController = TextEditingController();
  final TextEditingController _missingController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  double _identifiedProgress = 0.0; // 0..1
  double _missingProgress = 0.0;    // 0..1

  @override
  void dispose() {
    _identifiedController.dispose();
    _missingController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _onScan() {
    // TODO: itt lesz majd az AI / kamera hívás
    // demo: feltöltünk pár dummy adatot
    setState(() {
      _identifiedProgress = 231 / 200; // csak illusztráció
      _missingProgress = 231 / 31;
      _identifiedController.text = 'Example: 231/200 elements identified';
      _missingController.text = 'Example: 231/31 elements missing';
    });
  }

  void _onCancel() {
    Navigator.pop(context);
  }

  void _onReady() {
    // TODO: itt jelezheted backendnek, hogy kész a scan
    // pl. snackBar:
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Scan marked as ready')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5CB58),
      body: AppBackground(
        title: 'Element\nIdentifier',
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
              // Select set dropdown
              _SelectSetDropdown(
                value: _selectedSet,
                onChanged: (value) {
                  setState(() {
                    _selectedSet = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Camera preview placeholder
              Container(
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: const Center(
                  child: Text(
                    'Camera Preview',
                    style: TextStyle(
                      color: Color(0xFF848383),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Scan button
              Center(
                child: SizedBox(
                  width: 160,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD3D3D3),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    onPressed: _onScan,
                    child: const Text(
                      'Scan',
                      style: TextStyle(
                        color: Color(0xFF391713),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Identified elements
              const Text(
                'Identified Elements 231/200',
                style: TextStyle(
                  color: Color(0xFF252525),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: (_identifiedProgress > 1 ? 1 : _identifiedProgress),
                backgroundColor: Colors.grey[300],
                color: const Color(0xFF848383),
                minHeight: 6,
              ),
              const SizedBox(height: 8),
              _MultilineBox(controller: _identifiedController),
              const SizedBox(height: 16),

              // Missing elements
              const Text(
                'Missing Elements 231/31',
                style: TextStyle(
                  color: Color(0xFF252525),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: (_missingProgress > 1 ? 1 : _missingProgress),
                backgroundColor: Colors.grey[300],
                color: const Color(0xFF848383),
                minHeight: 6,
              ),
              const SizedBox(height: 8),
              _MultilineBox(controller: _missingController),
              const SizedBox(height: 16),

              // Message
              const Text(
                'Message:',
                style: TextStyle(
                  color: Color(0xFF252525),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              _MultilineBox(controller: _messageController),
              const SizedBox(height: 16),

              // Cancel / Ready gombok
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF391713),
                        side: BorderSide(color: Colors.grey[400]!),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      onPressed: _onCancel,
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD3D3D3),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      onPressed: _onReady,
                      child: const Text(
                        'Ready',
                        style: TextStyle(
                          color: Color(0xFF391713),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      // fontos: itt NINCS saját bottomNavigationBar,
      // mert a MainScreen már ad egyet a Scan tabhoz [file:11]
    );
  }
}

class _SelectSetDropdown extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  const _SelectSetDropdown({
    required this.value,
    required this.onChanged,
  });

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
        value: value,
        hint: const Text(
          'Select Set',
          style: TextStyle(
            color: Color(0xFF848383),
            fontSize: 14,
          ),
        ),
        isExpanded: true,
        underline: const SizedBox.shrink(),
        icon: const Icon(
          Icons.arrow_drop_down,
          color: Color(0xFF391713),
        ),
        items: const [
          // TODO: majd API-ból jön
        ],
        onChanged: onChanged,
      ),
    );
  }
}

class _MultilineBox extends StatelessWidget {
  final TextEditingController controller;

  const _MultilineBox({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: TextField(
        controller: controller,
        maxLines: null,
        decoration: const InputDecoration(
          border: InputBorder.none,
        ),
      ),
    );
  }
}
