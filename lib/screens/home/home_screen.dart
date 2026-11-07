import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../widgets/incident_card.dart';
import '../incident/incident_details_screen.dart';
import '../incident/report_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onBrowse;
  const HomeScreen({super.key, required this.onBrowse});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final inc = context.watch<IncidentProvider>();
    final text = Theme.of(context).textTheme;

    final firstName = (auth.profile?.name ?? '').split(' ').first;
    final isStaff = auth.isStaff;
    final mineOnly = !isStaff;

    final summary = isStaff
        ? '${inc.count(IncidentStatus.submitted)} new reports to review'
        : '${inc.count(IncidentStatus.inProgress, mineOnly: true)} of your reports in progress';

    final recent = inc.all.take(3).toList();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Text('Hello, $firstName', style: text.headlineLarge),
          const SizedBox(height: 4),
          Text(
            isStaff
                ? 'Review reports and keep students updated.'
                : 'Help keep our campus running.',
            style: text.bodyLarge?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 23,
                  backgroundColor: AppColors.amberSoft,
                  child: Icon(Icons.fact_check_outlined,
                      color: AppColors.brown),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(summary, style: text.titleSmall),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ActionTile(
                  label: 'Report an issue',
                  icon: Icons.warning_amber_rounded,
                  bg: AppColors.brown,
                  fg: AppColors.card,
                  iconColor: AppColors.amber,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ReportScreen()),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _ActionTile(
                  label: 'Browse reports',
                  icon: Icons.list_alt,
                  bg: AppColors.amber,
                  fg: AppColors.brown,
                  iconColor: AppColors.brown,
                  onTap: onBrowse,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatCard(
                value: isStaff ? inc.all.length : inc.mine.length,
                label: isStaff ? 'All reports' : 'My reports',
              ),
              const SizedBox(width: 10),
              _StatCard(
                value: inc.count(IncidentStatus.inProgress,
                    mineOnly: mineOnly),
                label: 'In progress',
              ),
              const SizedBox(width: 10),
              _StatCard(
                value:
                    inc.count(IncidentStatus.resolved, mineOnly: mineOnly),
                label: 'Resolved',
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text('Recent updates', style: text.titleMedium),
          const SizedBox(height: 10),
          if (inc.loading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (recent.isEmpty)
            Text(
              'No reports yet. Be the first to report an issue.',
              style: text.bodyMedium?.copyWith(color: AppColors.muted),
            )
          else
            for (final i in recent) ...[
              IncidentCard(
                incident: i,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => IncidentDetailsScreen(incidentId: i.id),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color bg;
  final Color fg;
  final Color iconColor;
  final VoidCallback onTap;

  const _ActionTile({
    required this.label,
    required this.icon,
    required this.bg,
    required this.fg,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: SizedBox(
          height: 112,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 34, color: iconColor),
              const SizedBox(height: 10),
              Text(
                label,
                style: TextStyle(
                    color: fg, fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final int value;
  final String label;
  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text('$value', style: Theme.of(context).textTheme.headlineMedium),
            Text(label,
                style:
                    const TextStyle(fontSize: 12, color: AppColors.muted)),
          ],
        ),
      ),
    );
  }
}