import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Optional photo input. Shows the newly picked file, else the existing
/// uploaded photo (when editing), else a "tap to add" placeholder.
class PhotoPickerField extends StatelessWidget {
  const PhotoPickerField({
    super.key,
    required this.picked,
    required this.onChanged,
    this.existingUrl,
  });

  final File? picked;
  final String? existingUrl;
  final ValueChanged<File?> onChanged;

  static const _height = 180.0;

  Future<void> _pick(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    // Resized + compressed on-device: faster uploads, lower storage cost.
    final file = await ImagePicker().pickImage(
      source: source,
      maxWidth: AppConfig.photoMaxDimension,
      maxHeight: AppConfig.photoMaxDimension,
      imageQuality: AppConfig.photoQuality,
    );
    if (file != null) onChanged(File(file.path));
  }

  @override
  Widget build(BuildContext context) {
    final image = picked != null
        ? Image.file(picked!, fit: BoxFit.cover)
        : existingUrl != null
            ? CachedNetworkImage(imageUrl: existingUrl!, fit: BoxFit.cover)
            : null;

    if (image == null) {
      return InkWell(
        onTap: () => _pick(context),
        borderRadius: AppRadius.card,
        child: Container(
          height: _height / 1.6,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.card,
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_photo_alternate_outlined,
                  color: AppColors.primary, size: 30),
              const SizedBox(height: AppSpacing.sm),
              Text('Tap to add a photo', style: AppTextStyles.bodySecondary),
            ],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: AppRadius.card,
      child: SizedBox(
        height: _height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            image,
            Positioned(
              top: AppSpacing.sm,
              right: AppSpacing.sm,
              child: Row(
                spacing: AppSpacing.sm,
                children: [
                  _OverlayButton(
                    icon: Icons.edit_outlined,
                    tooltip: 'Change photo',
                    onTap: () => _pick(context),
                  ),
                  // Only a freshly picked photo can be discarded here.
                  if (picked != null)
                    _OverlayButton(
                      icon: Icons.close_rounded,
                      tooltip: 'Remove photo',
                      onTap: () => onChanged(null),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverlayButton extends StatelessWidget {
  const _OverlayButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => IconButton.filled(
        tooltip: tooltip,
        onPressed: onTap,
        style: IconButton.styleFrom(backgroundColor: Colors.black54),
        icon: Icon(icon, color: Colors.white, size: 20),
      );
}
