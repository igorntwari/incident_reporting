import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/incident.dart';
import '../../domain/incident_enums.dart';
import '../incident_styles.dart';

/// Horizontal progress tracker: Submitted → In Progress → Resolved/Rejected.
class StatusTimeline extends StatelessWidget {
  const StatusTimeline({super.key, required this.incident});

  final Incident incident;

  @override
  Widget build(BuildContext context) {
    final finalStep = incident.status == IncidentStatus.rejected
        ? IncidentStatus.rejected
        : IncidentStatus.resolved;
    final steps = [
      IncidentStatus.submitted,
      IncidentStatus.inProgress,
      finalStep,
    ];
    final currentIndex = switch (incident.status) {
      IncidentStatus.submitted => 0,
      IncidentStatus.inProgress => 1,
      IncidentStatus.resolved || IncidentStatus.rejected => 2,
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          _Step(
            status: steps[i],
            reached: i <= currentIndex,
            isCurrent: i == currentIndex,
            date: i <= currentIndex
                ? incident.changeFor(steps[i])?.changedAt
                : null,
          ),
          if (i < steps.length - 1)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Divider(
                  thickness: 2,
                  color: i < currentIndex
                      ? AppColors.primary
                      : AppColors.border,
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.status,
    required this.reached,
    required this.isCurrent,
    this.date,
  });

  final IncidentStatus status;
  final bool reached;
  final bool isCurrent;
  final DateTime? date;

  @override
  Widget build(BuildContext context) {
    final color = reached ? status.color : AppColors.textMuted;
    return SizedBox(
      width: 84,
      child: Column(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: reached ? color : AppColors.border,
            child: Icon(
              reached && !isCurrent ? Icons.check_rounded : status.icon,
              size: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            status.label,
            style: AppTextStyles.label.copyWith(color: color),
            textAlign: TextAlign.center,
          ),
          Text(
            date == null ? '—' : Formatters.shortDate(date!),
            style: AppTextStyles.caption.copyWith(fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Full audit trail: every status change with who made it and their note.
class StatusHistoryList extends StatelessWidget {
  const StatusHistoryList({super.key, required this.history});

  final List<StatusChange> history;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          for (final change in history.reversed)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: change.status.surface,
                child: Icon(change.status.icon,
                    color: change.status.color, size: 20),
              ),
              title: Text(
                '${change.status.label} · ${change.changedBy}',
                style: AppTextStyles.subheading,
              ),
              subtitle: Text(
                [
                  Formatters.dateTime(change.changedAt),
                  if (change.note != null) '“${change.note}”',
                ].join('\n'),
                style: AppTextStyles.caption,
              ),
            ),
        ],
      );
}
