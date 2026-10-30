import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/ui_feedback.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../auth/application/auth_providers.dart';
import '../application/incident_providers.dart';
import '../domain/incident.dart';
import 'incident_styles.dart';
import 'widgets/incident_thumbnail.dart';
import 'widgets/status_badge.dart';
import 'widgets/status_timeline.dart';
import 'widgets/update_status_sheet.dart';

/// Live view of one incident: a staff status change appears here (and in
/// every list) immediately because it is backed by a Firestore stream.
class IncidentDetailsScreen extends ConsumerWidget {
  const IncidentDetailsScreen({super.key, required this.incidentId});

  final String incidentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listenForErrors(incidentActionsProvider, context);
    final incidentAsync = ref.watch(incidentByIdProvider(incidentId));
    final incident = incidentAsync.value;
    final user = ref.watch(currentUserProvider).value;
    final isStaff = user?.isStaff ?? false;
    final isOwner = incident != null && incident.reporterId == user?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Incident Details'),
        actions: [
          if (incident != null && (isStaff || isOwner))
            _ActionsMenu(incident: incident, isStaff: isStaff, isOwner: isOwner),
        ],
      ),
      body: AsyncValueView(
        value: incidentAsync,
        data: (incident) => incident == null
            ? const MessageView(
                icon: Icons.search_off_rounded,
                title: 'Report not found',
                message: 'It may have been withdrawn or removed.',
              )
            : _Details(
                incident: incident,
                // Privacy: reporter identity is shown only to staff and
                // to the reporter themselves, not to other students.
                showReporter: isStaff || isOwner,
              ),
      ),
      bottomNavigationBar: incident != null && isStaff
          ? SafeArea(
              minimum: const EdgeInsets.all(AppSpacing.lg),
              child: PrimaryButton(
                label: 'Update status',
                icon: Icons.sync_alt_rounded,
                onPressed: () => UpdateStatusSheet.show(context, incident),
              ),
            )
          : null,
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.incident, required this.showReporter});

  final Incident incident;
  final bool showReporter;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.md,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IncidentThumbnail(incident: incident, size: 72),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: AppSpacing.xs,
                        children: [
                          Text(incident.title, style: AppTextStyles.heading),
                          IconText(
                            icon: Icons.location_on_outlined,
                            text: incident.location,
                          ),
                          StatusBadge(incident.status),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(),
                IconText(
                  icon: incident.category.icon,
                  text: incident.category.label,
                ),
                IconText(
                  icon: Icons.calendar_today_outlined,
                  text: 'Submitted ${Formatters.dateTime(incident.createdAt)}',
                ),
                if (showReporter)
                  IconText(
                    icon: Icons.person_outline_rounded,
                    text: 'Reported by ${incident.reporterName}',
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: 'Status Timeline'),
          StatusTimeline(incident: incident),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: 'Description'),
          Text(incident.description, style: AppTextStyles.bodySecondary),
          if (incident.hasPhoto) ...[
            const SizedBox(height: AppSpacing.xl),
            const SectionHeader(title: 'Attached Photo'),
            _Photo(url: incident.photoUrl!),
          ],
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: 'Activity'),
          StatusHistoryList(history: incident.history),
        ],
      );
}

class _Photo extends StatelessWidget {
  const _Photo({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) => GestureDetector(
        // Tap to view full-screen with pinch-to-zoom.
        onTap: () => showDialog<void>(
          context: context,
          builder: (_) => Dialog.fullscreen(
            backgroundColor: Colors.black,
            child: Stack(
              children: [
                Center(
                  child: InteractiveViewer(
                    child: CachedNetworkImage(imageUrl: url),
                  ),
                ),
                SafeArea(
                  child: IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
        child: ClipRRect(
          borderRadius: AppRadius.card,
          child: CachedNetworkImage(
            imageUrl: url,
            height: 220,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      );
}

enum _MenuAction { edit, delete }

class _ActionsMenu extends ConsumerWidget {
  const _ActionsMenu({
    required this.incident,
    required this.isStaff,
    required this.isOwner,
  });

  final Incident incident;
  final bool isStaff;
  final bool isOwner;

  Future<void> _onSelected(
    BuildContext context,
    WidgetRef ref,
    _MenuAction action,
  ) async {
    switch (action) {
      case _MenuAction.edit:
        context.push(AppRoutes.editIncident(incident.id));
      case _MenuAction.delete:
        final confirmed = await context.confirm(
          title: isOwner ? 'Withdraw report?' : 'Delete report?',
          message: 'This permanently removes the report and its photo.',
          confirmLabel: 'Delete',
          destructive: true,
        );
        if (!confirmed || !context.mounted) return;
        final ok =
            await ref.read(incidentActionsProvider.notifier).delete(incident);
        if (ok && context.mounted) {
          context.showSnack('Report deleted');
          context.pop();
        }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Reporters can change or withdraw a report only until staff act on it;
    // staff can remove spam or duplicates at any time.
    final ownerCanModify = isOwner && incident.isEditableByReporter;
    final canDelete = isStaff || ownerCanModify;
    if (!canDelete) return const SizedBox.shrink();

    return PopupMenuButton<_MenuAction>(
      onSelected: (action) => _onSelected(context, ref, action),
      itemBuilder: (_) => [
        if (ownerCanModify)
          const PopupMenuItem(
            value: _MenuAction.edit,
            child: ListTile(
              leading: Icon(Icons.edit_outlined),
              title: Text('Edit'),
            ),
          ),
        if (canDelete)
          const PopupMenuItem(
            value: _MenuAction.delete,
            child: ListTile(
              leading: Icon(Icons.delete_outline_rounded, color: AppColors.danger),
              title: Text('Delete', style: TextStyle(color: AppColors.danger)),
            ),
          ),
      ],
    );
  }
}
