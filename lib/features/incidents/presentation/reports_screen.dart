import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../auth/application/auth_providers.dart';
import '../application/incident_providers.dart';
import '../domain/incident_filter.dart';
import 'widgets/incident_card.dart';
import 'widgets/incident_filter_bar.dart';

/// Browse, search and filter reports. Students switch between their own
/// reports and the campus feed (to spot duplicates); staff see everything.
class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isStaff = ref.watch(isStaffProvider);
    final filter = ref.watch(incidentFilterProvider);
    final incidents = ref.watch(filteredIncidentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isStaff ? 'All Reports' : 'Reports'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xxl * 2),
        children: [
          if (!isStaff) ...[
            SegmentedButton<IncidentScope>(
              segments: const [
                ButtonSegment(
                  value: IncidentScope.mine,
                  label: Text('My reports'),
                  icon: Icon(Icons.person_outline_rounded),
                ),
                ButtonSegment(
                  value: IncidentScope.campus,
                  label: Text('Campus'),
                  icon: Icon(Icons.apartment_rounded),
                ),
              ],
              selected: {filter.scope},
              onSelectionChanged: (s) => ref
                  .read(incidentFilterProvider.notifier)
                  .setScope(s.first),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          const IncidentFilterBar(),
          const SizedBox(height: AppSpacing.lg),
          AsyncValueView(
            value: incidents,
            data: (list) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${list.length} report${list.length == 1 ? '' : 's'}',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: AppSpacing.sm),
                IncidentList(
                  incidents: list,
                  emptyTitle: filter.hasActiveFilters
                      ? 'No matching reports'
                      : 'No reports yet',
                  emptyMessage: filter.hasActiveFilters
                      ? 'Try a different search or filter.'
                      : 'Tap + to report an issue on campus.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
