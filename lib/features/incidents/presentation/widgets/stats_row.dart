import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/incident_enums.dart';
import '../../domain/incident_filter.dart';
import '../incident_styles.dart';

/// The four summary tiles (Total / Submitted / In progress / Resolved)
/// shown on Home and Profile.
class StatsRow extends StatelessWidget {
  const StatsRow({super.key, required this.stats, required this.totalLabel});

  final IncidentStats stats;
  final String totalLabel;

  @override
  Widget build(BuildContext context) => Row(
        spacing: AppSpacing.sm,
        children: [
          _StatTile(
            value: stats.total,
            label: totalLabel,
            icon: Icons.description_outlined,
            color: AppColors.primary,
            surface: AppColors.primarySurface,
          ),
          _StatTile.status(IncidentStatus.submitted, stats.submitted),
          _StatTile.status(IncidentStatus.inProgress, stats.inProgress),
          _StatTile.status(IncidentStatus.resolved, stats.resolved),
        ],
      );
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    required this.surface,
  });

  _StatTile.status(IncidentStatus status, this.value)
      : label = status.label,
        icon = status.icon,
        color = status.color,
        surface = status.surface;

  final int value;
  final String label;
  final IconData icon;
  final Color color;
  final Color surface;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.md, horizontal: AppSpacing.xs),
          decoration:
              BoxDecoration(color: surface, borderRadius: AppRadius.card),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: AppSpacing.sm),
              Text('$value', style: AppTextStyles.title),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
}
