import 'package:cloud_firestore/cloud_firestore.dart';

class StatusUpdate {
  final String status;
  final String note;
  final String by;
  final DateTime at;

  const StatusUpdate({
    required this.status,
    required this.note,
    required this.by,
    required this.at,
  });

  factory StatusUpdate.fromMap(Map<String, dynamic> m) => StatusUpdate(
        status: m['status'] ?? '',
        note: m['note'] ?? '',
        by: m['by'] ?? '',
        at: (m['at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'status': status,
        'note': note,
        'by': by,
        'at': Timestamp.fromDate(at),
      };
}

class Incident {
  final String id;
  final String title;
  final String description;
  final String category;
  final String location;
  final String urgency;
  final String status;
  final String reporterId;
  final String? reporterName;
  final bool isAnonymous;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<StatusUpdate> history;

  const Incident({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.urgency,
    required this.status,
    required this.reporterId,
    required this.reporterName,
    required this.isAnonymous,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.history,
  });

  /// Short reference shown on cards, e.g. INC-7K2QX
  String get refId =>
      'INC-${id.substring(0, id.length < 5 ? id.length : 5).toUpperCase()}';

  String get reporterLabel =>
      isAnonymous ? 'Anonymous' : (reporterName ?? 'Unknown');

  factory Incident.fromMap(String id, Map<String, dynamic> m) {
    final created = (m['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    return Incident(
      id: id,
      title: m['title'] ?? '',
      description: m['description'] ?? '',
      category: m['category'] ?? 'Other',
      location: m['location'] ?? '',
      urgency: m['urgency'] ?? 'Medium',
      status: m['status'] ?? 'Submitted',
      reporterId: m['reporterId'] ?? '',
      reporterName: m['reporterName'] as String?,
      isAnonymous: m['isAnonymous'] ?? false,
      imageUrl: m['imageUrl'] as String?,
      createdAt: created,
      updatedAt: (m['updatedAt'] as Timestamp?)?.toDate() ?? created,
      history: ((m['history'] as List?) ?? [])
          .map((e) => StatusUpdate.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}