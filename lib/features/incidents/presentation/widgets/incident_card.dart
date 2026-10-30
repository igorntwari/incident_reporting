import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../domain/incident.dart';
import 'incident_thumbnail.dart';
import 'status_badge.dart';

class IncidentCard extends StatelessWidget {
  const IncidentCard({super.key, required this.incident});

  final Incident incident;

  @override
  Widget build(BuildContext context) => AppCard(
        onTap: () => context.push(AppRoutes.incidentDetails(incident.id)),
        child: Row(
          children: [
            IncidentThumbnail(incident: incident),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    incident.title,
                    style: AppTextStyles.subheading,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  IconText(
                      icon: Icons.location_on_outlined,
                      text: incident.location),
                  const SizedBox(height: AppSpacing.xs),
                  IconText(
                    icon: Icons.calendar_today_outlined,
                    text: Formatters.timeAgo(incident.createdAt),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            StatusBadge(incident.status),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          ],
        ),
      );
}

/// Vertical list of incident cards with a shared empty state.
/// Built as slivers-free Column so it can sit inside any scroll view.
class IncidentList extends StatelessWidget {
  const IncidentList({
    super.key,
    required this.incidents,
    required this.emptyTitle,
    this.emptyMessage,
  });

  final List<Incident> incidents;
  final String emptyTitle;
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (incidents.isEmpty) {
      return _EmptyIncidents(title: emptyTitle, message: emptyMessage);
    }
    return Column(
      children: [
        for (final incident in incidents)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: IncidentCard(incident: incident),
          ),
      ],
    );
  }
}

class _EmptyIncidents extends StatelessWidget {
  const _EmptyIncidents({required this.title, this.message});

  final String title;
  final String? message;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Column(
          children: [
            const Icon(Icons.inbox_outlined,
                size: 48, color: AppColors.textMuted),
            const SizedBox(height: AppSpacing.sm),
            Text(title, style: AppTextStyles.subheading),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(message!,
                  style: AppTextStyles.caption, textAlign: TextAlign.center),
            ],
          ],
        ),
      );
}
