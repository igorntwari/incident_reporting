import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/providers/action_controller.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../auth/application/auth_providers.dart';
import '../../auth/domain/app_user.dart';
import '../data/incident_repository.dart';
import '../domain/incident.dart';
import '../domain/incident_enums.dart';
import '../domain/incident_filter.dart';

final incidentRepositoryProvider = Provider(
  (ref) => IncidentRepository(
    ref.watch(firestoreProvider),
    ref.watch(storageProvider),
  ),
);

// ------------------------------------------------------------ data streams
// Each stream is keyed on the signed-in uid, so signing out tears down the
// Firestore listeners instead of leaving them to fail with permission errors.

final _uidProvider =
    Provider<String?>((ref) => ref.watch(authStateProvider).value?.uid);

final allIncidentsProvider = StreamProvider<List<Incident>>((ref) {
  if (ref.watch(_uidProvider) == null) return Stream.value(const []);
  return ref.watch(incidentRepositoryProvider).watchAll();
});

final myIncidentsProvider = StreamProvider<List<Incident>>((ref) {
  final uid = ref.watch(_uidProvider);
  if (uid == null) return Stream.value(const []);
  return ref.watch(incidentRepositoryProvider).watchByReporter(uid);
});

final incidentByIdProvider =
    StreamProvider.autoDispose.family<Incident?, String>(
  (ref, id) => ref.watch(incidentRepositoryProvider).watchById(id),
);

/// What a user's dashboard is about: their own reports for students,
/// every campus report for staff.
final dashboardIncidentsProvider = Provider<AsyncValue<List<Incident>>>(
  (ref) => ref.watch(isStaffProvider)
      ? ref.watch(allIncidentsProvider)
      : ref.watch(myIncidentsProvider),
);

final dashboardStatsProvider = Provider<AsyncValue<IncidentStats>>(
  (ref) => ref.watch(dashboardIncidentsProvider).whenData(IncidentStats.from),
);

// ----------------------------------------------------------- search/filter

final incidentFilterProvider =
    NotifierProvider<IncidentFilterNotifier, IncidentFilter>(
  IncidentFilterNotifier.new,
);

class IncidentFilterNotifier extends Notifier<IncidentFilter> {
  @override
  IncidentFilter build() => const IncidentFilter();

  void setQuery(String query) => state = state.copyWith(query: query);

  void setScope(IncidentScope scope) => state = state.copyWith(scope: scope);

  void setStatus(IncidentStatus? status) => state =
      state.copyWith(status: status, clearStatus: status == null);

  void setCategory(IncidentCategory? category) => state =
      state.copyWith(category: category, clearCategory: category == null);

  void clear() => state = IncidentFilter(scope: state.scope);
}

/// The reports list after scope, status, category and text search.
final filteredIncidentsProvider = Provider<AsyncValue<List<Incident>>>((ref) {
  final filter = ref.watch(incidentFilterProvider);
  final showCampus =
      ref.watch(isStaffProvider) || filter.scope == IncidentScope.campus;
  final source = showCampus
      ? ref.watch(allIncidentsProvider)
      : ref.watch(myIncidentsProvider);
  return source.whenData(filter.apply);
});

// ----------------------------------------------------------------- actions

final incidentActionsProvider =
    NotifierProvider<IncidentActions, AsyncValue<void>>(IncidentActions.new);

class IncidentActions extends ActionController {
  IncidentRepository get _repo => ref.read(incidentRepositoryProvider);

  /// Creates a new report, or updates [existing] when editing.
  Future<bool> submit(IncidentDraft draft, {Incident? existing}) => run(() {
        if (existing != null) return _repo.update(existing, draft);
        return _repo.create(draft, _requireUser());
      });

  Future<bool> updateStatus(
    Incident incident,
    IncidentStatus status, {
    String? note,
  }) =>
      run(() {
        final user = _requireUser();
        // UI hides the action for students; rules enforce it server-side.
        if (!user.isStaff) {
          throw const AppException('Only staff can update a report status.');
        }
        return _repo.updateStatus(
          incidentId: incident.id,
          status: status,
          staff: user,
          note: note,
        );
      });

  Future<bool> delete(Incident incident) => run(() => _repo.delete(incident));

  AppUser _requireUser() => ref.read(currentUserProvider).requireValue!;
}
