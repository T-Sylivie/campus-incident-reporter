import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/theme.dart';

class StatusStyle {
  final Color bg;
  final Color fg;
  final Color stripe;
  const StatusStyle(this.bg, this.fg, this.stripe);
}

StatusStyle statusStyle(String status) {
  switch (status) {
    case IncidentStatus.inProgress:
      return const StatusStyle(
          AppColors.progressBg, AppColors.progressFg, AppColors.progressStripe);
    case IncidentStatus.resolved:
      return const StatusStyle(
          AppColors.resolvedBg, AppColors.resolvedFg, AppColors.resolvedStripe);
    default:
      return const StatusStyle(AppColors.submittedBg, AppColors.submittedFg,
          AppColors.submittedStripe);
  }
}

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final s = statusStyle(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: s.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600, color: s.fg),
      ),
    );
  }
}

Color urgencyColor(String urgency) {
  switch (urgency) {
    case Urgency.high:
      return const Color(0xFFB3261E);
    case Urgency.low:
      return AppColors.resolvedFg;
    default:
      return const Color(0xFFB26A00);
  }
}

class UrgencyTag extends StatelessWidget {
  final String urgency;
  const UrgencyTag(this.urgency, {super.key});

  @override
  Widget build(BuildContext context) {
    final c = urgencyColor(urgency);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, size: 8, color: c),
        const SizedBox(width: 4),
        Text(
          '$urgency urgency',
          style:
              TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c),
        ),
      ],
    );
  }
}