import 'incident.dart';
import 'incident_enums.dart';

enum IncidentScope { mine, campus }

/// Immutable search/filter criteria for the reports list.
/// Filtering runs client-side on the live stream: at campus scale this keeps
/// queries simple and avoids a composite index per filter combination.
class IncidentFilter {
  const IncidentFilter({
    this.query = '',
    this.status,
    this.category,
    this.scope = IncidentScope.mine,
  });

  final String query;
  final IncidentStatus? status;
  final IncidentCategory? category;
  final IncidentScope scope;

  bool get hasActiveFilters =>
      query.trim().isNotEmpty || status != null || category != null;

  bool matches(Incident incident) {
    if (status != null && incident.status != status) return false;
    if (category != null && incident.category != category) return false;
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return true;
    return incident.title.toLowerCase().contains(needle) ||
        incident.location.toLowerCase().contains(needle) ||
        incident.description.toLowerCase().contains(needle);
  }

  List<Incident> apply(List<Incident> incidents) =>
      incidents.where(matches).toList();

  // Sentinel-free copyWith: nullable filters are cleared via dedicated flags.
  IncidentFilter copyWith({
    String? query,
    IncidentStatus? status,
    bool clearStatus = false,
    IncidentCategory? category,
    bool clearCategory = false,
    IncidentScope? scope,
  }) =>
      IncidentFilter(
        query: query ?? this.query,
        status: clearStatus ? null : status ?? this.status,
        category: clearCategory ? null : category ?? this.category,
        scope: scope ?? this.scope,
      );
}

/// Counts per status, used by the summary cards on Home and Profile.
class IncidentStats {
  const IncidentStats({
    required this.total,
    required this.submitted,
    required this.inProgress,
    required this.resolved,
  });

  factory IncidentStats.from(List<Incident> incidents) {
    int count(IncidentStatus s) =>
        incidents.where((i) => i.status == s).length;
    return IncidentStats(
      total: incidents.length,
      submitted: count(IncidentStatus.submitted),
      inProgress: count(IncidentStatus.inProgress),
      resolved: count(IncidentStatus.resolved),
    );
  }

  final int total;
  final int submitted;
  final int inProgress;
  final int resolved;
}
