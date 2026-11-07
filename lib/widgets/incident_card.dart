import 'package:flutter/material.dart';
import '../core/helpers.dart';
import '../core/theme.dart';
import '../models/incident.dart';
import 'status_badge.dart';

class IncidentCard extends StatelessWidget {
  final Incident incident;
  final VoidCallback onTap;

  const IncidentCard({super.key, required this.incident, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final i = incident;
    final stripe = statusStyle(i.status).stripe;
    const muted = TextStyle(fontSize: 12, color: AppColors.muted);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 6, color: stripe),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(categoryIcon(i.category),
                                size: 16, color: AppColors.muted),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text('${i.refId} · ${i.category}',
                                  style: muted),
                            ),
                            Text(timeAgo(i.createdAt), style: muted),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          i.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.place_outlined,
                                size: 14, color: AppColors.muted),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                i.location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 13, color: AppColors.muted),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            StatusBadge(i.status),
                            const SizedBox(width: 12),
                            UrgencyTag(i.urgency),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}