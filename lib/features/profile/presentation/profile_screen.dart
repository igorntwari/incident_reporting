import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/ui_feedback.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../auth/application/auth_providers.dart';
import '../../auth/domain/app_user.dart';
import '../../incidents/application/incident_providers.dart';
import '../../incidents/presentation/widgets/stats_row.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await context.confirm(
      title: 'Sign out?',
      message: 'You will need to sign in again to report or track issues.',
      confirmLabel: 'Sign out',
    );
    // The router sends the user to login once the session ends.
    if (confirmed) await ref.read(authControllerProvider.notifier).signOut();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        appBar: AppBar(title: const Text('Profile'), centerTitle: false),
        body: AsyncValueView(
          value: ref.watch(currentUserProvider),
          data: (user) => user == null
              ? const LoadingView()
              : ListView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    _ProfileHeader(user: user),
                    const SizedBox(height: AppSpacing.lg),
                    AsyncValueView(
                      value: ref.watch(dashboardStatsProvider),
                      data: (stats) => StatsRow(
                        stats: stats,
                        totalLabel: user.isStaff ? 'All reports' : 'My reports',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.mail_outline_rounded),
                            title: const Text('Email'),
                            subtitle: Text(user.email),
                          ),
                          if (user.createdAt != null)
                            ListTile(
                              leading: const Icon(Icons.event_outlined),
                              title: const Text('Member since'),
                              subtitle:
                                  Text(Formatters.dateTime(user.createdAt!)),
                            ),
                          ListTile(
                            leading: const Icon(Icons.privacy_tip_outlined),
                            title: const Text('Privacy'),
                            subtitle: const Text(
                              'Other students see your reports without your '
                              'name. Only campus staff can see who reported.',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    OutlinedButton.icon(
                      onPressed: () => _signOut(context, ref),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                      ),
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Sign out'),
                    ),
                  ],
                ),
        ),
      );
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) => AppCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            UserAvatar(initials: user.initials, size: 64),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpacing.xs,
                children: [
                  Text(user.fullName, style: AppTextStyles.title),
                  Text(user.email, style: AppTextStyles.caption),
                ],
              ),
            ),
            Pill(
              label: user.role.label,
              color: user.isStaff ? AppColors.success : AppColors.primary,
              background: user.isStaff
                  ? AppColors.successSurface
                  : AppColors.primarySurface,
            ),
          ],
        ),
      );
}
