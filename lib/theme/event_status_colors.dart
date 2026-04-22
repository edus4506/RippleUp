import 'package:flutter/material.dart';
import '../data/models/event_status.dart';

Color getEventStatusColor(EventStatus status) {
  switch (status) {
    case EventStatus.planning:
      return Colors.orange;
    case EventStatus.occurring:
      return Colors.green;
    case EventStatus.done:
      return Colors.grey;
  }
}