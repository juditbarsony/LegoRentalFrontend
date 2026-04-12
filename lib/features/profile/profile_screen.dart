import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lego_rental_frontend/core/models/review_model.dart';
import 'package:lego_rental_frontend/core/models/user_model.dart';
import 'package:lego_rental_frontend/core/services/users_service.dart';
import 'package:lego_rental_frontend/core/theme/app_colors.dart';
import 'package:lego_rental_frontend/core/widgets/app_background.dart';
import 'package:lego_rental_frontend/core/widgets/app_dropdown.dart';
import 'package:lego_rental_frontend/core/widgets/app_primary_button.dart';
import 'package:lego_rental_frontend/core/widgets/app_text_field.dart';
import 'package:lego_rental_frontend/features/auth/auth_providers.dart';
import 'package:lego_rental_frontend/features/friends/friends_service.dart';
import 'package:lego_rental_frontend/features/home/home_screen.dart';
import 'package:lego_rental_frontend/features/reviews/data/review_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _obscurePassword = true;
  late FriendsService friendsService;
  late UsersService usersService;

  List<UserModel> friends = [];
  List<UserModel> availableUsers = [];

  bool isLoadingFriends = true;
  bool isLoadingUsers = true;
  bool isActionLoading = false;
  String? errorMessage;
  int? selectedUserId;

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

        if (!mounted) return;
      }

      if (userId != null) {
        ref.read(reviewProvider.notifier).loadUserReviews(userId: userId);
      }
    });
  }

  Future<void> loadFriends() async {
    final result = await friendsService!.getFriends();
    if (!mounted) return;
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
      backgroundColor: AppColors.brandHeader,
      body: AppBackground(
        title: 'My Profile',
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
            children: [
              const SizedBox(height: 24),
              Stack(
                children: [
                  const CircleAvatar(
                    radius: 60,
                    backgroundImage: AssetImage('assets/images/bj_lego.JPG'),
                    backgroundColor: Colors.transparent,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
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
              const SizedBox(height: 28),
              _ProfileField(
                label: 'Full name',
                value: 'Bársony Judit',
                readOnly: true,
              ),
              const SizedBox(height: 16),
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
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _ProfileField(
                label: 'Email',
                value: 'test@lego.com',
                readOnly: true,
              ),
              const SizedBox(height: 16),
              _ProfileField(
                label: 'Mobile number',
                value: '+ 123 456 789',
              ),
              const SizedBox(height: 16),
              _ProfileField(
                label: 'Location (City)',
                value: 'Budapest',
              ),
              const SizedBox(height: 24),
              AppPrimaryButton(
                label: 'Update Profile',
                onPressed: () {
                  // TODO: update profile logic
                },
              ),
              const SizedBox(height: 20),
              _SectionCard(
                title: 'Friends',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isLoadingUsers)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: CircularProgressIndicator(),
                      )
                    else if (availableUsers.isEmpty)
                      Text(
                        'No available users found.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textMuted,
                            ),
                      )
                    else
                      AppDropdown<int>(
                        label: 'Select user',
                        hintText: 'Choose a user',
                        value: selectedUserId,
                        enabled: !isActionLoading,
                        items: availableUsers.map((user) {
                          return DropdownMenuItem<int>(
                            value: user.id,
                            child: Text(
                              user.fullName,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: AppColors.text,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedUserId = value;
                          });
                        },
                      ),
                    const SizedBox(height: 12),
                    AppPrimaryButton(
                      label: isActionLoading ? 'Adding...' : 'Add friend',
                      onPressed: (selectedUserId == null || isActionLoading)
                          ? null
                          : addSelectedFriend,
                    ),
                    if (errorMessage != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        errorMessage!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.red,
                            ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    if (isLoadingFriends)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: CircularProgressIndicator(),
                      )
                    else if (friends.isEmpty)
                      Text(
                        'No friends yet.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textMuted,
                            ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: friends.length,
                        separatorBuilder: (_, __) => const Divider(height: 16),
                        itemBuilder: (context, index) {
                          final friend = friends[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const CircleAvatar(
                              radius: 18,
                              backgroundImage:
                                  AssetImage('assets/images/Untitled-2.png'),
                              backgroundColor: Colors.transparent,
                            ),
                            title: Text(
                              friend.fullName,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppColors.text,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            subtitle: Text(
                              friend.email,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.textMuted,
                                  ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              onPressed: isActionLoading
                                  ? null
                                  : () => deleteFriend(friend.id),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _SectionCard(
                title: 'Received reviews',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.red,
                            ),
                      )
                    else if (reviews.isEmpty)
                      Text(
                        'No reviews yet.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textMuted,
                            ),
                      )
                    else ...[
                      Row(
                        children: [
                          _buildStars(averageRating.round()),
                          const SizedBox(width: 8),
                          Text(
                            '${averageRating.toStringAsFixed(1)} / 5',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.text,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${reviews.length} reviews)',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textMuted,
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
    return AppTextField(
      label: label,
      hintText: value,
      obscureText: obscureText,
      readOnly: readOnly,
      suffixIcon: suffixIcon,
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.text,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
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
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Review #${review.id}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.text,
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
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.text,
                    height: 1.3,
                  ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            review.createdAt,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                ),
          ),
        ],
      ),
    );
  }
}
