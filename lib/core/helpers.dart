import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'constants.dart';

IconData categoryIcon(String name) {
  for (final c in incidentCategories) {
    if (c.name == name) return c.icon;
  }
  return Icons.more_horiz;
}

String timeAgo(DateTime t) {
  final d = DateTime.now().difference(t);
  if (d.inSeconds < 60) return 'just now';
  if (d.inMinutes < 60) return '${d.inMinutes} min ago';
  if (d.inHours < 24) return '${d.inHours} h ago';
  if (d.inDays < 7) return '${d.inDays} d ago';
  return DateFormat('d MMM yyyy').format(t);
}

String formatDateTime(DateTime t) =>
    DateFormat('d MMM yyyy, h:mm a').format(t);