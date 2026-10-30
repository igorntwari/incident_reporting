import 'package:flutter/material.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/validators.dart';

/// Free-text location with suggestions of common campus places, so users can
/// be specific ("Block B — Room 204") while still typing quickly.
class LocationField extends StatefulWidget {
  const LocationField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  State<LocationField> createState() => _LocationFieldState();
}

class _LocationFieldState extends State<LocationField> {
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RawAutocomplete<String>(
        textEditingController: widget.controller,
        focusNode: _focusNode,
        optionsBuilder: (value) {
          final query = value.text.toLowerCase();
          return AppConfig.campusLocations
              .where((l) => l.toLowerCase().contains(query));
        },
        fieldViewBuilder: (context, controller, focusNode, onSubmitted) =>
            TextFormField(
          controller: controller,
          focusNode: focusNode,
          validator: (v) => Validators.required(v, 'Location'),
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'e.g. Block B — Room 204',
            prefixIcon: Icon(Icons.location_on_outlined),
          ),
        ),
        optionsViewBuilder: (context, onSelected, options) => Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: AppRadius.input,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220, maxWidth: 320),
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                shrinkWrap: true,
                children: [
                  for (final option in options)
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.place_outlined, size: 20),
                      title: Text(option),
                      onTap: () => onSelected(option),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
}
