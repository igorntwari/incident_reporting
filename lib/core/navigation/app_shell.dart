import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_routes.dart';

/// Bottom navigation (Home / Reports / Profile) with a centred
/// "Report" action, matching the design mock-ups.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  static const _tabs = [
    (icon: Icons.home_outlined, active: Icons.home_rounded, label: 'Home'),
    (
      icon: Icons.description_outlined,
      active: Icons.description_rounded,
      label: 'Reports'
    ),
    (icon: Icons.person_outline_rounded, active: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        body: shell,
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.push(AppRoutes.newReport),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
          tooltip: 'Report an issue',
          child: const Icon(Icons.add_rounded, size: 30),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          color: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          child: Row(
            children: [
              _tab(0),
              _tab(1),
              const SizedBox(width: 64), // space for the FAB
              _tab(2),
            ],
          ),
        ),
      );

  Widget _tab(int index) {
    final tab = _tabs[index];
    final selected = shell.currentIndex == index;
    final color = selected ? AppColors.primary : AppColors.textSecondary;
    return Expanded(
      child: InkResponse(
        // Re-tapping the active tab pops it back to its root.
        onTap: () => shell.goBranch(index, initialLocation: selected),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(selected ? tab.active : tab.icon, color: color),
            Text(tab.label, style: AppTextStyles.label.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}
