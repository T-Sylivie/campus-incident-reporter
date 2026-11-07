import '../models/incident.dart';

/// A pure function, so it can be unit-tested without Firebase.
List<Incident> filterIncidents(
  List<Incident> all, {
  String query = '',
  String? status,
  String? category,
}) {
  final q = query.trim().toLowerCase();
  return all.where((i) {
    if (status != null && i.status != status) return false;
    if (category != null && i.category != category) return false;
    if (q.isEmpty) return true;
    return i.title.toLowerCase().contains(q) ||
        i.description.toLowerCase().contains(q) ||
        i.location.toLowerCase().contains(q) ||
        i.category.toLowerCase().contains(q) ||
        i.refId.toLowerCase().contains(q);
  }).toList();
}