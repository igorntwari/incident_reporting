import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/incident_enums.dart';
import '../incident_styles.dart';

/// Grid of category tiles. Wrapped in a [FormField] so "no category picked"
/// is reported through the same validation flow as the text fields.
class CategorySelector extends FormField<IncidentCategory> {
  CategorySelector({
    super.key,
    super.initialValue,
    required ValueChanged<IncidentCategory> onChanged,
  }) : super(
          validator: (value) => value == null ? 'Select a category' : null,
          builder: (field) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppSpacing.sm,
                crossAxisSpacing: AppSpacing.sm,
                childAspectRatio: 0.95,
                children: [
                  for (final category in IncidentCategory.values)
                    _CategoryTile(
                      category: category,
                      selected: field.value == category,
                      onTap: () {
                        field.didChange(category);
                        onChanged(category);
                      },
                    ),
                ],
              ),
              if (field.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Text(field.errorText!,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.danger)),
                ),
            ],
          ),
        );
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final IncidentCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? Colors.white : AppColors.primary;
    return Semantics(
      selected: selected,
      button: true,
      label: category.label,
      child: Material(
        color: selected ? AppColors.primary : AppColors.primarySurface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(category.icon, color: foreground),
              const SizedBox(height: AppSpacing.xs),
              Text(
                category.label,
                style: AppTextStyles.label.copyWith(
                  color: selected ? Colors.white : AppColors.textPrimary,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
