import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Gradient call-to-action card at the top of Home.
class HeroCard extends StatelessWidget {
  const HeroCard({
    super.key,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.actionIcon,
    required this.onAction,
  });

  final String title;
  final String message;
  final String actionLabel;
  final IconData actionIcon;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          gradient: AppColors.heroGradient,
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            const Positioned(
              right: -12,
              bottom: 40,
              child: Icon(Icons.apartment_rounded,
                  size: 120, color: Colors.white24),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTextStyles.title.copyWith(color: Colors.white)),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    width: 220,
                    child: Text(
                      message,
                      style:
                          AppTextStyles.body.copyWith(color: Colors.white70),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Material(
                    color: AppColors.surface,
                    borderRadius: AppRadius.card,
                    child: ListTile(
                      onTap: onAction,
                      shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.card),
                      leading: CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.primary,
                        child: Icon(actionIcon, color: Colors.white, size: 20),
                      ),
                      title: Text(
                        actionLabel,
                        style: AppTextStyles.subheading
                            .copyWith(color: AppColors.primary),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded,
                          color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
