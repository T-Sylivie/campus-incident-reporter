import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/helpers.dart';
import '../../core/theme.dart';
import '../../models/incident.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/staff_status_panel.dart';

class IncidentDetailsScreen extends StatelessWidget {
  final String incidentId;
  const IncidentDetailsScreen({super.key, required this.incidentId});

  Future<void> _confirmDelete(BuildContext context, Incident i) async {
    final navigator = Navigator.of(context);
    final provider = context.read<IncidentProvider>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this report?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) {
      navigator.pop();
      await provider.delete(i.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final i = context.watch<IncidentProvider>().byId(incidentId);
    final auth = context.watch<AuthProvider>();
    final text = Theme.of(context).textTheme;

    if (i == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Report')),
        body: const Center(child: Text('This report is no longer available.')),
      );
    }

    final isOwner = auth.profile?.uid == i.reporterId;
    final canDelete = isOwner && i.status == IncidentStatus.submitted;

    return Scaffold(
      appBar: AppBar(title: Text(i.refId)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            if (i.imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  i.imageUrl!,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => Container(
                    height: 120,
                    color: AppColors.amberSoft,
                    alignment: Alignment.center,
                    child: const Text('Photo unavailable'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(i.title, style: text.headlineMedium),
            const SizedBox(height: 10),
            Row(
              children: [
                StatusBadge(i.status),
                const SizedBox(width: 12),
                UrgencyTag(i.urgency),
              ],
            ),
            const SizedBox(height: 16),
            _InfoRow(Icons.category_outlined, 'Category', i.category),
            _InfoRow(Icons.place_outlined, 'Location', i.location),
            _InfoRow(Icons.person_outline, 'Reported by', i.reporterLabel),
            _InfoRow(Icons.schedule, 'Submitted', formatDateTime(i.createdAt)),
            const SizedBox(height: 16),
            Text('Description', style: text.titleMedium),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(i.description, style: text.bodyLarge),
            ),
            const SizedBox(height: 22),
            Text('Status timeline', style: text.titleMedium),
            const SizedBox(height: 12),
            _Timeline(incident: i),
            if (auth.isStaff) ...[
              const SizedBox(height: 20),
              StaffStatusPanel(incident: i),
            ],
            if (canDelete) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => _confirmDelete(context, i),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete my report'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.muted),
          const SizedBox(width: 10),
          SizedBox(
            width: 92,
            child: Text(label,
                style: const TextStyle(color: AppColors.muted)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  final Incident incident;
  const _Timeline({required this.incident});

  @override
  Widget build(BuildContext context) {
    final reached = incident.history.map((h) => h.status).toSet();
    final pending =
        IncidentStatus.all.where((s) => !reached.contains(s)).toList();

    final steps = <Widget>[];
    final total = incident.history.length + pending.length;
    var index = 0;

    for (var n = 0; n < incident.history.length; n++) {
      final h = incident.history[n];
      final isCurrent = n == incident.history.length - 1;
      steps.add(_Step(
        title: h.status,
        subtitle: '${h.by} · ${formatDateTime(h.at)}',
        note: h.note,
        dotColor: isCurrent ? AppColors.orange : AppColors.brown,
        filled: true,
        isLast: ++index == total,
      ));
    }
    for (final s in pending) {
      steps.add(_Step(
        title: s,
        subtitle: 'Pending',
        note: '',
        dotColor: AppColors.border,
        filled: false,
        isLast: ++index == total,
      ));
    }
    return Column(children: steps);
  }
}

class _Step extends StatelessWidget {
  final String title;
  final String subtitle;
  final String note;
  final Color dotColor;
  final bool filled;
  final bool isLast;

  const _Step({
    required this.title,
    required this.subtitle,
    required this.note,
    required this.dotColor,
    required this.filled,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled ? dotColor : AppColors.card,
                    border: Border.all(
                      color: filled ? dotColor : AppColors.muted,
                      width: 2,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 2, color: AppColors.border),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.muted)),
                  if (note.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(note),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}