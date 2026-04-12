import 'package:flutter/material.dart';
import 'package:lego_rental_frontend/core/theme/app_colors.dart';
import 'package:lego_rental_frontend/core/widgets/app_background.dart';
import 'package:lego_rental_frontend/core/widgets/app_primary_button.dart';
import 'package:lego_rental_frontend/core/widgets/app_text_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _mobileController = TextEditingController();
  final _locationController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _mobileController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brandHeader,
      body: AppBackground(
        title: 'New Account',
        onBack: () => Navigator.pop(context),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    Text(
                      'Create your account',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.text,
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                    ),

                    const SizedBox(height: 24),

                    AppTextField(
                      label: 'Email',
                      controller: _emailController,
                      hintText: 'example@example.com',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Invalid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    AppTextField(
                      label: 'Password',
                      controller: _passwordController,
                      hintText: 'Enter your password',
                      obscureText: _obscurePassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 6) {
                          return 'At least 6 characters';
                        }
                        return null;
                      },
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

                    AppTextField(
                      label: 'Full name',
                      controller: _fullNameController,
                      hintText: 'Your full name',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    AppTextField(
                      label: 'Mobile number',
                      controller: _mobileController,
                      hintText: 'Optional',
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return null;
                        }
                        if (value.trim().length < 7) {
                          return 'Too short';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    AppTextField(
                      label: 'Location (City)',
                      controller: _locationController,
                      hintText: 'e.g. Budapest',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your city';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    AppPrimaryButton(
                      label: 'Sign Up',
                      onPressed: _submit,
                    ),

                    const SizedBox(height: 16),

                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text.rich(
                          TextSpan(
                            text: 'Already have an account? ',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.text,
                                ),
                            children: [
                              TextSpan(
                                text: 'Log in',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}