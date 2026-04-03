import 'package:flutter/material.dart';
import 'package:t5/data/models/event.dart';

class EventDetailsPage extends StatelessWidget {
  final Event event;

  const EventDetailsPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(event.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              event.description,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Text(
              "Objectives: ${event.objectives.join(', ')}",
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              "Country: ${event.country}",
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              "District: ${event.district}",
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              "City: ${event.city}",
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              "Max Users: ${event.maxUsers}",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}