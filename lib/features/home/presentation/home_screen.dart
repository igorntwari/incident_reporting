import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../auth/application/auth_providers.dart';
import '../../auth/domain/app_user.dart';
import '../../incidents/application/incident_providers.dart';
import '../../incidents/domain/incident_enums.dart';
import '../../incidents/presentation/widgets/incident_card.dart';
import '../../incidents/presentation/widgets/stats_row.dart';
import 'widgets/hero_card.dart';

/// Role-aware dashboard: students see their own reports, staff see a
/// campus-wide overview with a shortcut to the triage queue.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        body: SafeArea(
          child: AsyncValueView(
            value: ref.watch(currentUserProvider),
            data: (user) => user == null
                ? const LoadingView() // profile doc is still being created
                : _Dashboard(user: user),
          ),
        ),
      );
}

class _Dashboard extends ConsumerWidget {
  const _Dashboard({required this.user});

  final AppUser user;

  /// Jumps to the Reports tab with a status filter pre-applied.
  void _openReports(BuildContext context, WidgetRef ref,
      [IncidentStatus? status]) {
    ref.read(incidentFilterProvider.notifier)
      ..clear()
      ..setStatus(status);
    context.go(AppRoutes.reports);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(dashboardStatsProvider);
    final incidents = ref.watch(dashboardIncidentsProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xxl * 2),
      children: [
        _Greeting(user: user),
        const SizedBox(height: AppSpacing.xl),
        if (user.isStaff)
          HeroCard(
            title: 'Reports waiting for review',
            message: '${stats.value?.submitted ?? 0} new reports need triage.',
            actionLabel: 'Review new reports',
            actionIcon: Icons.fact_check_outlined,
            onAction: () => _openReports(context, ref, IncidentStatus.submitted),
          )
        else
          HeroCard(
            title: 'See an issue on campus?',
            message: 'Report it and help improve our learning environment.',
            actionLabel: 'Report an Issue',
            actionIcon: Icons.add_rounded,
            onAction: () => context.push(AppRoutes.newReport),
          ),
        const SizedBox(height: AppSpacing.xl),
        SectionHeader(
          title: 'Report Summary',
          actionLabel: 'See all',
          onAction: () => _openReports(context, ref),
        ),
        AsyncValueView(
          value: stats,
          data: (s) => StatsRow(
            stats: s,
            totalLabel: user.isStaff ? 'All reports' : 'My reports',
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        SectionHeader(
          title: 'Recent Reports',
          actionLabel: 'See all',
          onAction: () => _openReports(context, ref),
        ),
        AsyncValueView(
          value: incidents,
          data: (list) => IncidentList(
            incidents: list.take(AppConfig.recentReportsLimit).toList(),
            emptyTitle: 'No reports yet',
            emptyMessage: user.isStaff
                ? 'New campus reports will appear here.'
                : 'Your reports will appear here once submitted.',
          ),
        ),
      ],
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.xs,
              children: [
                Text('Hello, ${user.firstName} 👋',
                    style: AppTextStyles.display),
                Text(
                  user.isStaff
                      ? 'Review reports and keep students updated.'
                      : 'Help make our campus safer.\n'
                          'Report issues and track their resolution.',
                  style: AppTextStyles.bodySecondary,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => context.go(AppRoutes.profile),
            child: UserAvatar(initials: user.initials, size: 52),
          ),
        ],
      );
}
