import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants.dart';
import '../models/app_user.dart';
import '../models/incident.dart';

class IncidentService {
  final CollectionReference<Map<String, dynamic>> _col =
      FirebaseFirestore.instance.collection('incidents');

  /// Live stream of all reports, newest first.
  Stream<List<Incident>> watchAll() {
    return _col.orderBy('createdAt', descending: true).snapshots().map(
          (snap) =>
              snap.docs.map((d) => Incident.fromMap(d.id, d.data())).toList(),
        );
  }

  Future<String> create({
    required AppUser reporter,
    required String title,
    required String description,
    required String category,
    required String location,
    required String urgency,
    required bool isAnonymous,
    String? imageUrl,
  }) async {
    final doc = _col.doc();
    final first = StatusUpdate(
      status: IncidentStatus.submitted,
      note: 'Report submitted',
      by: isAnonymous ? 'Anonymous' : reporter.name,
      at: DateTime.now(),
    );
    await doc.set({
      'title': title.trim(),
      'description': description.trim(),
      'category': category,
      'location': location,
      'urgency': urgency,
      'status': IncidentStatus.submitted,
      'isAnonymous': isAnonymous,
      'reporterId': reporter.uid,
      if (!isAnonymous) 'reporterName': reporter.name,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'history': [first.toMap()],
    });
    return doc.id;
  }

  /// Staff only (enforced by security rules, added in a later step).
  Future<void> updateStatus({
    required String id,
    required String status,
    required String note,
    required AppUser staff,
  }) {
    final update = StatusUpdate(
      status: status,
      note: note.trim(),
      by: staff.name,
      at: DateTime.now(),
    );
    return _col.doc(id).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
      'history': FieldValue.arrayUnion([update.toMap()]),
    });
  }

  Future<void> delete(String id) => _col.doc(id).delete();
}