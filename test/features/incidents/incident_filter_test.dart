import 'package:flutter_test/flutter_test.dart';
import 'package:incident_reporting/features/incidents/domain/incident.dart';
import 'package:incident_reporting/features/incidents/domain/incident_enums.dart';
import 'package:incident_reporting/features/incidents/domain/incident_filter.dart';

Incident _incident(
  String title, {
  IncidentStatus status = IncidentStatus.submitted,
  IncidentCategory category = IncidentCategory.facilities,
  String location = 'Block B',
}) {
  final now = DateTime(2026, 10, 30);
  return Incident(
    id: title,
    title: title,
    description: 'Description for $title',
    category: category,
    location: location,
    status: status,
    reporterId: 'uid',
    reporterName: 'Amina Hassan',
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  final incidents = [
    _incident('Water shortage',
        category: IncidentCategory.water, location: 'Student Residence'),
    _incident('Broken projector', status: IncidentStatus.inProgress),
    _incident('Overflowing bin',
        status: IncidentStatus.resolved,
        category: IncidentCategory.sanitation,
        location: 'Cafeteria'),
  ];

  group('IncidentFilter', () {
    test('empty filter returns everything', () {
      expect(const IncidentFilter().apply(incidents), hasLength(3));
      expect(const IncidentFilter().hasActiveFilters, isFalse);
    });

    test('filters by status', () {
      final result = const IncidentFilter(status: IncidentStatus.inProgress)
          .apply(incidents);
      expect(result.single.title, 'Broken projector');
    });

    test('filters by category', () {
      final result = const IncidentFilter(category: IncidentCategory.water)
          .apply(incidents);
      expect(result.single.title, 'Water shortage');
    });

    test('searches title and location, case-insensitively, ignoring spaces',
        () {
      expect(const IncidentFilter(query: ' PROJECTOR ').apply(incidents),
          hasLength(1));
      expect(const IncidentFilter(query: 'cafeteria').apply(incidents),
          hasLength(1));
      expect(const IncidentFilter(query: '   ').hasActiveFilters, isFalse);
    });

    test('combines criteria', () {
      const filter = IncidentFilter(
          query: 'bin', status: IncidentStatus.submitted);
      expect(filter.apply(incidents), isEmpty);
    });

    test('copyWith can clear nullable filters', () {
      const filter = IncidentFilter(
          status: IncidentStatus.resolved, category: IncidentCategory.water);
      final cleared = filter.copyWith(clearStatus: true, clearCategory: true);
      expect(cleared.status, isNull);
      expect(cleared.category, isNull);
    });
  });

  test('IncidentStats counts by status', () {
    final stats = IncidentStats.from(incidents);
    expect(stats.total, 3);
    expect(stats.submitted, 1);
    expect(stats.inProgress, 1);
    expect(stats.resolved, 1);
  });

  group('IncidentStatus workflow', () {
    test('closed statuses can only be reopened', () {
      expect(IncidentStatus.resolved.nextStatuses, [IncidentStatus.inProgress]);
      expect(IncidentStatus.rejected.isClosed, isTrue);
    });

    test('a status never transitions to itself', () {
      for (final status in IncidentStatus.values) {
        expect(status.nextStatuses, isNot(contains(status)));
      }
    });

    test('unknown stored values fall back safely', () {
      expect(IncidentStatus.fromName('bogus'), IncidentStatus.submitted);
      expect(IncidentCategory.fromName(null), IncidentCategory.other);
    });
  });
}
