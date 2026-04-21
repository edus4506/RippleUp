import 'package:flutter/material.dart';
import '../../data/models/event.dart';
import '../../../data/models/event_status.dart';

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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: onTap,

        title: Text(event.title),

        subtitle: RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: [
              TextSpan(
                text: '${event.city}, ${event.district} — ',
              ),
              TextSpan(
                text: event.status.text,
                style: TextStyle(
                  color: event.status.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}