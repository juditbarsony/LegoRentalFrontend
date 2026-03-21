import 'package:flutter/material.dart'; 
import 'package:lego_rental_frontend/core/widgets/app_background.dart';
import 'package:lego_rental_frontend/features/home/home_screen.dart';









class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5CB58),
      body: AppBackground(
        title: 'My profile',
        onBack: null,
        onHome: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false, // mindent kidob a stackből, tiszta Home
          );
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 24),

              // Profilkép
              Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[300],
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.grey,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF848383),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Full name
              _ProfileField(
                label: 'Full name',
                value: 'example@example.com',
                readOnly: true,
              ),

              const SizedBox(height: 16),

              // Password
              _ProfileField(
                label: 'Password',
                value: '**************',
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFF848383),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Email
              _ProfileField(label: 'Email', value: 'example@example.com'),

              const SizedBox(height: 16),

              // Mobile Number
              _ProfileField(label: 'Mobile Number', value: '+ 123 456 789'),

              const SizedBox(height: 16),

              // Location (City)
              _ProfileField(label: 'Location (City)', value: 'Budapest'),

              const SizedBox(height: 32),

              // Update Profile gomb
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF848383),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 48,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  // TODO: update profile logic
                },
                child: const Text(
                  'Update Profile',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final String value;
  final bool readOnly;
  final bool obscureText;
  final Widget? suffixIcon;

  const _ProfileField({
    required this.label,
    required this.value,
    this.readOnly = false,
    this.obscureText = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF391713),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          readOnly: readOnly,
          obscureText: obscureText,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF3E9B5),
            hintText: value,
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
