import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../domain/incident_enums.dart';

/// Visual mapping for domain enums. Kept in the presentation layer so the
/// domain stays free of Flutter types.
extension IncidentStatusStyle on IncidentStatus {
  Color get color => switch (this) {
        IncidentStatus.submitted => AppColors.warning,
        IncidentStatus.inProgress => AppColors.primary,
        IncidentStatus.resolved => AppColors.success,
        IncidentStatus.rejected => AppColors.danger,
      };

  Color get surface => switch (this) {
        IncidentStatus.submitted => AppColors.warningSurface,
        IncidentStatus.inProgress => AppColors.primarySurface,
        IncidentStatus.resolved => AppColors.successSurface,
        IncidentStatus.rejected => AppColors.dangerSurface,
      };

  IconData get icon => switch (this) {
        IncidentStatus.submitted => Icons.error_outline_rounded,
        IncidentStatus.inProgress => Icons.schedule_rounded,
        IncidentStatus.resolved => Icons.check_circle_outline_rounded,
        IncidentStatus.rejected => Icons.block_rounded,
      };
}

extension IncidentCategoryStyle on IncidentCategory {
  IconData get icon => switch (this) {
        IncidentCategory.facilities => Icons.apartment_rounded,
        IncidentCategory.water => Icons.water_drop_outlined,
        IncidentCategory.electricity => Icons.bolt_rounded,
        IncidentCategory.furniture => Icons.chair_outlined,
        IncidentCategory.sanitation => Icons.delete_outline_rounded,
        IncidentCategory.safety => Icons.shield_outlined,
        IncidentCategory.other => Icons.more_horiz_rounded,
      };
}
