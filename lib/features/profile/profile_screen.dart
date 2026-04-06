import 'package:flutter/material.dart';
import 'package:lego_rental_frontend/core/models/user_model.dart';
import 'package:lego_rental_frontend/core/services/users_service.dart';
import 'package:lego_rental_frontend/core/widgets/app_background.dart';
import 'package:lego_rental_frontend/features/friends/friends_service.dart';
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
  late FriendsService friendsService;

  List<UserModel> friends = [];
  bool isLoadingFriends = true;
  bool isActionLoading = false;
  String? errorMessage;
  int? selectedUserId;

  late UsersService usersService;
  List<UserModel> availableUsers = [];
  bool isLoadingUsers = true;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final authState = ref.read(authProvider);
      final userId = authState.userId;
      final token = authState.accessToken;

      if (token != null) {
        friendsService = FriendsService(token: token);
        usersService = UsersService(token: token);
        await Future.wait([
          loadFriends(),
          loadAvailableUsers(),
        ]);
      }

      if (userId != null) {
        ref.read(reviewProvider.notifier).loadUserReviews(userId: userId);
      }
    });
  }

  Future<void> loadFriends() async {
    setState(() {
      isLoadingFriends = true;
      errorMessage = null;
    });

    try {
      final result = await friendsService.getFriends();
      setState(() {
        friends = result;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        isLoadingFriends = false;
      });
    }
  }

  Future<void> addSelectedFriend() async {
    if (selectedUserId == null) return;

    setState(() {
      isActionLoading = true;
      errorMessage = null;
    });

    try {
      await friendsService.addFriend(selectedUserId!);
      await loadFriends();
      setState(() {
        selectedUserId = null;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Barát sikeresen hozzáadva')),
      );
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (!mounted) return;
      setState(() {
        isActionLoading = false;
      });
    }
  }

  Future<void> deleteFriend(int friendId) async {
    setState(() {
      isActionLoading = true;
      errorMessage = null;
    });

    try {
      await friendsService.deleteFriend(friendId);
      await loadFriends();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Barát eltávolítva')),
      );
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (!mounted) return;
      setState(() {
        isActionLoading = false;
      });
    }
  }

  Future<void> loadAvailableUsers() async {
    setState(() {
      isLoadingUsers = true;
    });

    try {
      final users = await usersService.getUsers();
      setState(() {
        availableUsers = users;
      });
    } catch (e) {
      setState(() {
        errorMessage ??= e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        isLoadingUsers = false;
      });
    }
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
                value: 'Bársony Judit',
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
              _ProfileField(label: 'Email', value: 'test@lego.com'),

              const SizedBox(height: 16),

              // Mobile Number
              _ProfileField(label: 'Mobile Number', value: '+ 123 456 789'),

              const SizedBox(height: 16),

              // Location (City)
              _ProfileField(label: 'Location (City)', value: 'Budapest'),

              const SizedBox(height: 16),

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
              // --- FRIENDS BLOKK KEZDETE ---

              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Friends',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),


              if (isLoadingUsers)
                const CircularProgressIndicator()
              else if (availableUsers.isEmpty)
                const Text('Nincs más elérhető felhasználó.')
              else
                DropdownButtonFormField<int>(
                  value: selectedUserId,
                  decoration: const InputDecoration(
                    labelText: 'Select user',
                    border: OutlineInputBorder(),
                  ),
                  items: availableUsers.map((user) {
                    return DropdownMenuItem<int>(
                      value: user.id,
                      child: Text(user.fullName),
                    );
                  }).toList(),
                  onChanged: isActionLoading
                      ? null
                      : (value) {
                          setState(() {
                            selectedUserId = value;
                          });
                        },
                ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (selectedUserId == null || isActionLoading)
                      ? null
                      : addSelectedFriend,
                  child: isActionLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Add friend'),
                ),
              ),

              const SizedBox(height: 12),

              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              if (isLoadingFriends)
                const CircularProgressIndicator()
              else if (friends.isEmpty)
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('No friends yet.'),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: friends.length,
                  itemBuilder: (context, index) {
                    final friend = friends[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(friend.fullName),
                      subtitle: Text(friend.email),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: isActionLoading
                            ? null
                            : () => deleteFriend(friend.id),
                      ),
                    );
                  },
                ),

              // --- FRIENDS BLOKK VÉGE ---


              const SizedBox(height: 32),



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
