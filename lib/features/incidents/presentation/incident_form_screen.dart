import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/utils/ui_feedback.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/widgets/async_value_view.dart';
import '../application/incident_providers.dart';
import '../data/incident_repository.dart';
import '../domain/incident.dart';
import '../domain/incident_enums.dart';
import 'widgets/category_selector.dart';
import 'widgets/location_field.dart';
import 'widgets/photo_picker_field.dart';

/// One screen for both creating and editing a report.
/// With [incidentId] it loads that report and opens in edit mode.
class IncidentFormScreen extends ConsumerWidget {
  const IncidentFormScreen({super.key, this.incidentId});

  final String? incidentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditing = incidentId != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Report' : 'Report an Incident')),
      body: isEditing
          ? AsyncValueView(
              value: ref.watch(incidentByIdProvider(incidentId!)),
              data: (incident) => incident == null
                  ? const MessageView(
                      icon: Icons.search_off_rounded,
                      title: 'Report not found',
                    )
                  : _IncidentForm(initial: incident),
            )
          : const _IncidentForm(),
    );
  }
}

class _IncidentForm extends ConsumerStatefulWidget {
  const _IncidentForm({this.initial});

  final Incident? initial;

  @override
  ConsumerState<_IncidentForm> createState() => _IncidentFormState();
}

class _IncidentFormState extends ConsumerState<_IncidentForm> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.initial?.title);
  late final _description =
      TextEditingController(text: widget.initial?.description);
  late final _location = TextEditingController(text: widget.initial?.location);
  late IncidentCategory? _category = widget.initial?.category;
  File? _photo;

  bool get _isEditing => widget.initial != null;

  @override
  void dispose() {
    for (final c in [_title, _description, _location]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final draft = IncidentDraft(
      title: _title.text.trim(),
      description: _description.text.trim(),
      category: _category!,
      location: _location.text.trim(),
      photo: _photo,
    );
    final ok = await ref
        .read(incidentActionsProvider.notifier)
        .submit(draft, existing: widget.initial);
    if (!ok || !mounted) return;

    context.showSnack(_isEditing
        ? 'Report updated'
        : 'Report submitted. Track its progress under Reports.');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    ref.listenForErrors(incidentActionsProvider, context);
    final isLoading = ref.watch(incidentActionsProvider).isLoading;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          LabeledField(
            label: 'Select a category',
            child: CategorySelector(
              initialValue: _category,
              onChanged: (c) => _category = c,
            ),
          ),
          LabeledField(
            label: 'Title',
            child: TextFormField(
              controller: _title,
              validator: Validators.title,
              maxLength: AppConfig.titleMaxLength,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              decoration:
                  const InputDecoration(hintText: 'Briefly describe the issue'),
            ),
          ),
          LabeledField(
            label: 'Description',
            child: TextFormField(
              controller: _description,
              validator: Validators.description,
              maxLines: 5,
              maxLength: AppConfig.descriptionMaxLength,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'What happened, since when, and who is affected?',
              ),
            ),
          ),
          LabeledField(
            label: 'Location',
            child: LocationField(controller: _location),
          ),
          LabeledField(
            label: 'Add a photo',
            hint: '(optional)',
            child: PhotoPickerField(
              picked: _photo,
              existingUrl: widget.initial?.photoUrl,
              onChanged: (file) => setState(() => _photo = file),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          PrimaryButton(
            label: _isEditing ? 'Save changes' : 'Submit Report',
            isLoading: isLoading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
