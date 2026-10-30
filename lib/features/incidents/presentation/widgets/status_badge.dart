import 'package:flutter/material.dart';

import '../../../../core/widgets/app_widgets.dart';
import '../../domain/incident_enums.dart';
import '../incident_styles.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge(this.status, {super.key});

  final IncidentStatus status;

  @override
  Widget build(BuildContext context) =>
      Pill(label: status.label, color: status.color, background: status.surface);
}
