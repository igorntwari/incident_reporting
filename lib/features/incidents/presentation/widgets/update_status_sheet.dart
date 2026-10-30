import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/ui_feedback.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../application/incident_providers.dart';
import '../../domain/incident.dart';
import '../../domain/incident_enums.dart';
import '../incident_styles.dart';

/// Staff-only bottom sheet to move an incident to its next status, with an
/// optional note the reporter will see in the activity log.
class UpdateStatusSheet extends ConsumerStatefulWidget {
  const UpdateStatusSheet({super.key, required this.incident});

  final Incident incident;

  static Future<void> show(BuildContext context, Incident incident) =>
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => UpdateStatusSheet(incident: incident),
      );

  @override
  ConsumerState<UpdateStatusSheet> createState() => _UpdateStatusSheetState();
}

class _UpdateStatusSheetState extends ConsumerState<UpdateStatusSheet> {
  late IncidentStatus _selected = widget.incident.status.nextStatuses.first;
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final rejecting = _selected == IncidentStatus.rejected;
    if (rejecting && _note.text.trim().isEmpty) {
      context.showSnack('Add a note explaining why it was rejected.',
          isError: true);
      return;
    }
    final ok = await ref
        .read(incidentActionsProvider.notifier)
        .updateStatus(widget.incident, _selected, note: _note.text);
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
      context.showSnack('Status updated to ${_selected.label}');
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listenForErrors(incidentActionsProvider, context);
    final isLoading = ref.watch(incidentActionsProvider).isLoading;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Update status', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              for (final status in widget.incident.status.nextStatuses)
                ChoiceChip(
                  selected: _selected == status,
                  onSelected: (_) => setState(() => _selected = status),
                  selectedColor: status.color,
                  avatar: Icon(status.icon,
                      size: 16,
                      color: _selected == status ? Colors.white : status.color),
                  label: Text(
                    status.label,
                    style: AppTextStyles.label.copyWith(
                      color: _selected == status
                          ? Colors.white
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _note,
            maxLines: 3,
            maxLength: 300,
            decoration: const InputDecoration(
              hintText: 'Note for the reporter (e.g. "Plumber assigned")',
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          PrimaryButton(
            label: 'Save',
            isLoading: isLoading,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
