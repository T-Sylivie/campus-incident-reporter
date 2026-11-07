import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_incident_reporter/models/incident.dart';

void main() {
  test('refId uses the first five characters of the id, uppercased', () {
    final i = Incident.fromMap('abcde12345', {'title': 'T'});
    expect(i.refId, 'INC-ABCDE');
  });

  test('refId copes with very short ids', () {
    expect(Incident.fromMap('xyz', {}).refId, 'INC-XYZ');
  });

  test('anonymous reports show "Anonymous" instead of a name', () {
    final anon = Incident.fromMap('a1', {
      'isAnonymous': true,
      'reporterName': 'Should not be shown',
    });
    final named = Incident.fromMap('a2', {
      'isAnonymous': false,
      'reporterName': 'Amina',
    });
    expect(anon.reporterLabel, 'Anonymous');
    expect(named.reporterLabel, 'Amina');
  });

  test('fromMap reads the status history and applies defaults', () {
    final i = Incident.fromMap('xyz', {
      'title': 'Leak',
      'history': [
        {
          'status': 'Submitted',
          'note': 'Report submitted',
          'by': 'Amina',
          'at': Timestamp.fromDate(DateTime(2026, 11, 7, 10, 24)),
        },
      ],
    });
    expect(i.history.length, 1);
    expect(i.history.first.note, 'Report submitted');
    expect(i.category, 'Other');
    expect(i.status, 'Submitted');
    expect(i.urgency, 'Medium');
    expect(i.isAnonymous, isFalse);
  });

  test('StatusUpdate survives a toMap/fromMap round trip', () {
    final original = StatusUpdate(
      status: 'In Progress',
      note: 'Plumber dispatched',
      by: 'Staff',
      at: DateTime(2026, 11, 8, 9, 30),
    );
    final copy = StatusUpdate.fromMap(original.toMap());
    expect(copy.status, original.status);
    expect(copy.note, original.note);
    expect(copy.by, original.by);
    expect(copy.at.isAtSameMomentAs(original.at), isTrue);
  });
}