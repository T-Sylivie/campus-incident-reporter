import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../models/incident.dart';
import '../providers/incident_provider.dart';
import 'loading_button.dart';

class StaffStatusPanel extends StatefulWidget {
  final Incident incident;
  const StaffStatusPanel({super.key, required this.incident});

  @override
  State<StaffStatusPanel> createState() => _StaffStatusPanelState();
}

class _StaffStatusPanelState extends State<StaffStatusPanel> {
  final _note = TextEditingController();
  late String _status = widget.incident.status;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final note = _note.text.trim();
    final messenger = ScaffoldMessenger.of(context);

    if (_status == widget.incident.status && note.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Choose a new status or add a note.')),
      );
      return;
    }

    final provider = context.read<IncidentProvider>();
    final ok = await provider.updateStatus(widget.incident.id, _status, note);
    if (!mounted) return;

    if (ok) {
      _note.clear();
      messenger.showSnackBar(
        const SnackBar(content: Text('Status updated.')),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Update failed.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.watch<IncidentProvider>().busy;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.amberSoft.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.orange),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.admin_panel_settings_outlined,
                  color: AppColors.brown),
              const SizedBox(width: 8),
              Text('Staff: update status',
                  style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (final s in IncidentStatus.all)
                ChoiceChip(
                  label: Text(s),
                  selected: _status == s,
                  onSelected: (_) => setState(() => _status = s),
                  selectedColor: AppColors.brown,
                  backgroundColor: AppColors.card,
                  checkmarkColor: AppColors.card,
                  labelStyle: TextStyle(
                    color: _status == s ? AppColors.card : AppColors.ink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _note,
            minLines: 2,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Add a note for the student (optional)',
            ),
          ),
          const SizedBox(height: 12),
          LoadingButton(
            label: 'Update status',
            loading: busy,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}