import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../application/incident_providers.dart';
import '../../domain/incident_enums.dart';
import '../incident_styles.dart';

/// Search box plus status and category chip rows. Reads and writes the
/// shared [incidentFilterProvider], so filters set elsewhere (e.g. tapping
/// "Needs attention" on Home) show up here too.
class IncidentFilterBar extends ConsumerStatefulWidget {
  const IncidentFilterBar({super.key});

  @override
  ConsumerState<IncidentFilterBar> createState() => _IncidentFilterBarState();
}

class _IncidentFilterBarState extends ConsumerState<IncidentFilterBar> {
  late final _search =
      TextEditingController(text: ref.read(incidentFilterProvider).query);

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Keep the text box in sync when the filter is reset from elsewhere.
    ref.listen(incidentFilterProvider.select((f) => f.query), (_, query) {
      if (_search.text != query) _search.text = query;
    });
    final filter = ref.watch(incidentFilterProvider);
    final notifier = ref.read(incidentFilterProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.sm,
      children: [
        TextField(
          controller: _search,
          onChanged: notifier.setQuery,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Search title, location or details',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: filter.query.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear search',
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () {
                      _search.clear();
                      notifier.setQuery('');
                    },
                  ),
          ),
        ),
        _ChipRow(
          children: [
            _FilterChip(
              label: 'All',
              selected: filter.status == null,
              onTap: () => notifier.setStatus(null),
            ),
            for (final status in IncidentStatus.values)
              _FilterChip(
                label: status.label,
                selected: filter.status == status,
                onTap: () => notifier.setStatus(status),
              ),
          ],
        ),
        _ChipRow(
          children: [
            _FilterChip(
              label: 'All categories',
              selected: filter.category == null,
              onTap: () => notifier.setCategory(null),
            ),
            for (final category in IncidentCategory.values)
              _FilterChip(
                label: category.label,
                icon: category.icon,
                selected: filter.category == category,
                onTap: () => notifier.setCategory(category),
              ),
          ],
        ),
      ],
    );
  }
}

class _ChipRow extends StatelessWidget {
  const _ChipRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(spacing: AppSpacing.sm, children: children),
      );
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.white : AppColors.textPrimary;
    return ChoiceChip(
      selected: selected,
      onSelected: (_) => onTap(),
      avatar: icon == null ? null : Icon(icon, size: 16, color: color),
      label: Text(label, style: AppTextStyles.label.copyWith(color: color)),
    );
  }
}
