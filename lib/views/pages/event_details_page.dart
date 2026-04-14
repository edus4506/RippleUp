import 'package:flutter/material.dart';
import 'package:t5/data/models/event.dart';

class EventDetailsPage extends StatelessWidget {
  final Event event;

  const EventDetailsPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(event.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Event title
            Text(
              event.title,
              style: theme.textTheme.titleMedium?.copyWith(fontSize: 24),
            ),

            const SizedBox(height: 10),

            /// Description
            Text(
              event.description,
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 18),
            ),

            const SizedBox(height: 20)

            /// Event details
            /*Text(
              "Objectives: ${event.objectives.join(', ')}",
              style: theme.textTheme.bodyMedium,
            ),
            Text(
              "Country: ${event.country}",
              style: theme.textTheme.bodyMedium,
            ),
            Text(
              "District: ${event.district}",
              style: theme.textTheme.bodyMedium,
            ),
            Text(
              "City: ${event.city}",
              style: theme.textTheme.bodyMedium,
            ),
            Text(
              "Max Users: ${event.maxUsers}",
              style: theme.textTheme.bodyMedium,
            ),*/
          ],
        ),
      ),
    );
  }
}