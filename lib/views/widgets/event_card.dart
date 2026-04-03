import 'package:flutter/material.dart';
import '../../data/models/event.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                children: [
                  Expanded(
                    child: Text(
                      event.name,
                      style: textTheme.titleMedium,
                    ),
                  ),

                  if (event.isFull)
                    Text(
                      'FULL',
                      style: textTheme.labelMedium,
                    )
                  else
                    Row(
                      children: [
                        const Icon(Icons.people, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '${event.currentUsers}',
                          style: textTheme.bodyLarge, // 👈 vem do theme
                        ),
                      ],
                    ),
                ],
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  const Icon(Icons.location_on, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    '${event.city}, ${event.district}',
                    style: textTheme.bodyMedium,
                  ),
                ],
              ),

              const SizedBox(height: 6),

              Text(
                'Objective ${event.objectives.join(', ')}',
                style: textTheme.labelMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}