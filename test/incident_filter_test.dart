import 'package:flutter_test/flutter_test.dart';
import 'package:campus_incident_reporter/core/incident_filter.dart';
import 'package:campus_incident_reporter/models/incident.dart';

Incident make(String id, String title, String category, String location,
        String status) =>
    Incident(
      id: id,
      title: title,
      description: 'Details for $title',
      category: category,
      location: location,
      urgency: 'Medium',
      status: status,
      reporterId: 'u1',
      reporterName: 'Amina',
      isAnonymous: false,
      imageUrl: null,
      createdAt: DateTime(2026, 11, 7),
      updatedAt: DateTime(2026, 11, 7),
      history: const [],
    );

void main() {
  final a = make('aaaaa11111', 'Water shortage', 'Water',
      'Student Residence', 'Submitted');
  final b = make('bbbbb22222', 'Broken projector', 'Facilities',
      'Classroom Block', 'In Progress');
  final c = make('ccccc33333', 'Overflowing bin', 'Sanitation', 'Cafeteria',
      'Resolved');
  final all = [a, b, c];

  test('no filters returns everything', () {
    expect(filterIncidents(all), all);
  });

  test('filters by status', () {
    expect(filterIncidents(all, status: 'In Progress'), [b]);
  });

  test('filters by category', () {
    expect(filterIncidents(all, category: 'Sanitation'), [c]);
  });

  test('search is case-insensitive and covers title, location and ref id', () {
    expect(filterIncidents(all, query: 'PROJECTOR'), [b]);
    expect(filterIncidents(all, query: 'cafeteria'), [c]);
    expect(filterIncidents(all, query: 'inc-aaaaa'), [a]);
  });

  test('filters combine', () {
    expect(
      filterIncidents(all, status: 'Resolved', category: 'Sanitation'),
      [c],
    );
    expect(
      filterIncidents(all, status: 'Resolved', category: 'Water'),
      isEmpty,
    );
  });
}