import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../widgets/incident_card.dart';
import 'incident_details_screen.dart';
import 'report_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _search = TextEditingController();
  bool _mineOnly = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.brown,
        backgroundColor: AppColors.card,
        checkmarkColor: AppColors.card,
        labelStyle: TextStyle(
          color: selected ? AppColors.card : AppColors.ink,
          fontWeight: FontWeight.w600,
        ),
        side: const BorderSide(color: AppColors.border),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inc = context.watch<IncidentProvider>();
    final uid = context.watch<AuthProvider>().profile?.uid;

    var list = inc.filtered;
    if (_mineOnly) list = list.where((i) => i.reporterId == uid).toList();

    final hasFilters = inc.query.isNotEmpty ||
        inc.statusFilter != null ||
        inc.categoryFilter != null ||
        _mineOnly;

    Widget body;
    if (inc.loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (inc.error != null && inc.all.isEmpty) {
      body = Center(child: Text(inc.error!));
    } else if (list.isEmpty) {
      body = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined,
                size: 48, color: AppColors.muted),
            const SizedBox(height: 8),
            Text(hasFilters
                ? 'No reports match your filters.'
                : 'No reports yet.'),
            if (hasFilters)
              TextButton(
                onPressed: () {
                  _search.clear();
                  inc.clearFilters();
                  setState(() => _mineOnly = false);
                },
                child: const Text('Clear filters'),
              ),
          ],
        ),
      );
    } else {
      body = ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
        itemCount: list.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) => IncidentCard(
          incident: list[index],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  IncidentDetailsScreen(incidentId: list[index].id),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ReportScreen()),
        ),
        backgroundColor: AppColors.orange,
        foregroundColor: AppColors.brown,
        icon: const Icon(Icons.add),
        label: const Text('Report'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: TextField(
              controller: _search,
              onChanged: inc.setQuery,
              decoration: InputDecoration(
                hintText: 'Search reports',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: inc.query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _search.clear();
                          inc.setQuery('');
                        },
                      ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('All reports')),
                  ButtonSegment(value: true, label: Text('My reports')),
                ],
                selected: {_mineOnly},
                onSelectionChanged: (s) =>
                    setState(() => _mineOnly = s.first),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _chip('All', inc.statusFilter == null,
                    () => inc.setStatusFilter(null)),
                for (final s in IncidentStatus.all)
                  _chip(s, inc.statusFilter == s, () => inc.setStatusFilter(s)),
              ],
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _chip('Any category', inc.categoryFilter == null,
                    () => inc.setCategoryFilter(null)),
                for (final c in incidentCategories)
                  _chip(c.name, inc.categoryFilter == c.name,
                      () => inc.setCategoryFilter(c.name)),
              ],
            ),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}