enum IncidentCategory {
  facilities('Facilities'),
  water('Water'),
  electricity('Electricity'),
  furniture('Furniture'),
  sanitation('Sanitation'),
  safety('Safety'),
  other('Other');

  const IncidentCategory(this.label);
  final String label;

  static IncidentCategory fromName(String? name) =>
      values.firstWhere((c) => c.name == name, orElse: () => other);
}

enum IncidentStatus {
  submitted('Submitted'),
  inProgress('In Progress'),
  resolved('Resolved'),
  rejected('Rejected');

  const IncidentStatus(this.label);
  final String label;

  static IncidentStatus fromName(String? name) =>
      values.firstWhere((s) => s.name == name, orElse: () => submitted);

  /// A report is "closed" once staff have resolved or rejected it.
  bool get isClosed => this == resolved || this == rejected;

  /// The statuses staff may move a report to from this one.
  List<IncidentStatus> get nextStatuses => switch (this) {
        submitted => const [inProgress, resolved, rejected],
        inProgress => const [resolved, rejected],
        resolved || rejected => const [inProgress],
      };
}
