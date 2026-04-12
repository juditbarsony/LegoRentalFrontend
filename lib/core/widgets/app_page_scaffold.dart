import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';

class AppPageScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;
  final bool useSafeArea;

  const AppPageScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.useSafeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: child,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      body: useSafeArea ? SafeArea(child: content) : content,
    );
  }
}