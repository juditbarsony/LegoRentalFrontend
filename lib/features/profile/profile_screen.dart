import 'package:flutter/material.dart';
import 'package:lego_rental_frontend/core/widgets/app_background.dart';
import 'package:lego_rental_frontend/features/home/home_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lego_rental_frontend/features/auth/auth_providers.dart';
import 'package:lego_rental_frontend/features/reviews/data/review_provider.dart';
import 'package:lego_rental_frontend/core/models/review_model.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _obscurePassword = true;

  String? _selectedFriend;
  final List<String> _allUsers = [
    'Anna Kovács',
    'Bence Nagy',
    'Réka Tóth',
    'Dániel Szabó',
    'Eszter Varga',
  ];

  final List<String> _friends = [
    'Anna Kovács',
  ];

  void _addFriend() {
    if (_selectedFriend == null) return;
    if (_friends.contains(_selectedFriend)) return;

    setState(() {
      _friends.add(_selectedFriend!);
      _selectedFriend = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Friend added.')),
    );
  }

  void _removeFriend(String name) {
    setState(() {
      _friends.remove(name);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Friend removed.')),
    );
  }

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final authState = ref.read(authProvider);
      final userId = authState.userId;

      if (userId != null) {
        ref.read(reviewProvider.notifier).loadUserReviews(userId: userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final reviewState = ref.watch(reviewProvider);
    final reviews = reviewState.reviews;

    final averageRating = reviews.isEmpty
        ? 0.0
        : reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;

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
              const SizedBox(height: 32),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Friends',
                      style: TextStyle(
                        color: Color(0xFF391713),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Friends can see sets marked as "Friends only".',
                      style: TextStyle(
                        color: Color(0xFF848383),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: _selectedFriend,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Select user',
                        labelStyle: const TextStyle(
                          color: Color(0xFF848383),
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF9F9F9),
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
                      items: _allUsers
                          .where((u) => !_friends.contains(u))
                          .map(
                            (user) => DropdownMenuItem<String>(
                              value: user,
                              child: Text(
                                user,
                                style: const TextStyle(
                                  color: Color(0xFF391713),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() => _selectedFriend = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF391713),
                          side: BorderSide(color: Colors.grey[400]!),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _selectedFriend == null ? null : _addFriend,
                        child: const Text('Add friend'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'My friends',
                      style: TextStyle(
                        color: Color(0xFF391713),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_friends.isEmpty)
                      const Text(
                        'No friends added yet.',
                        style: TextStyle(
                          color: Color(0xFF848383),
                          fontSize: 13,
                        ),
                      )
                    else
                      Column(
                        children: _friends.map((friend) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9F9F9),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  radius: 14,
                                  backgroundColor: Color(0xFFE0E0E0),
                                  child: Icon(
                                    Icons.person,
                                    size: 16,
                                    color: Color(0xFF848383),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    friend,
                                    style: const TextStyle(
                                      color: Color(0xFF252525),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _removeFriend(friend),
                                  icon: const Icon(
                                    Icons.close,
                                    size: 18,
                                    color: Color(0xFF848383),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Received reviews',
                      style: TextStyle(
                        color: Color(0xFF391713),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (reviewState.isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (reviewState.errorMessage != null)
                      Text(
                        reviewState.errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 13,
                        ),
                      )
                    else if (reviews.isEmpty)
                      const Text(
                        'No reviews yet.',
                        style: TextStyle(
                          color: Color(0xFF848383),
                          fontSize: 13,
                        ),
                      )
                    else ...[
                      Row(
                        children: [
                          _buildStars(averageRating.round()),
                          const SizedBox(width: 8),
                          Text(
                            '${averageRating.toStringAsFixed(1)} / 5',
                            style: const TextStyle(
                              color: Color(0xFF252525),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${reviews.length} reviews)',
                            style: const TextStyle(
                              color: Color(0xFF848383),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ...reviews.map((review) => _ReviewCard(review: review)),
                    ],
                  ],
                ),
              ),
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

Widget _buildStars(int rating) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(5, (index) {
      return Icon(
        index < rating ? Icons.star : Icons.star_border,
        size: 18,
        color: const Color(0xFFFFC107),
      );
    }),
  );
}

class _ReviewCard extends StatelessWidget {
  final ReviewModel review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Review #${review.id}',
                  style: const TextStyle(
                    color: Color(0xFF391713),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _buildStars(review.rating),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.comment!,
              style: const TextStyle(
                color: Color(0xFF252525),
                fontSize: 13,
                height: 1.3,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            review.createdAt,
            style: const TextStyle(
              color: Color(0xFF848383),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
