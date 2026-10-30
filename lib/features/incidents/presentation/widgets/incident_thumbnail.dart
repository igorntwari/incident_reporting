import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../domain/incident.dart';
import '../incident_styles.dart';

/// The incident photo, or its category icon when no photo was attached.
class IncidentThumbnail extends StatelessWidget {
  const IncidentThumbnail({
    super.key,
    required this.incident,
    this.size = AppSizes.thumbnail,
  });

  final Incident incident;
  final double size;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      color: AppColors.primarySurface,
      child: Icon(incident.category.icon,
          color: AppColors.primary, size: size * 0.42),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: SizedBox.square(
        dimension: size,
        child: incident.hasPhoto
            ? CachedNetworkImage(
                imageUrl: incident.photoUrl!,
                fit: BoxFit.cover,
                placeholder: (_, _) => placeholder,
                errorWidget: (_, _, _) => placeholder,
              )
            : placeholder,
      ),
    );
  }
}
