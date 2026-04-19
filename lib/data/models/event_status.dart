import 'package:flutter/material.dart';

enum EventStatus {
  planning,
  occurring,
  done,
}

extension EventStatusExtension on EventStatus {
  String get text {
    switch (this) {
      case EventStatus.planning:
        return 'PLANNING';
      case EventStatus.occurring:
        return 'OCCURRING';
      case EventStatus.done:
        return 'DONE';
    }
  }

  Color get color {
    switch (this) {
      case EventStatus.planning:
        return Colors.orange;
      case EventStatus.occurring:
        return Colors.green;
      case EventStatus.done:
        return Colors.grey;
    }
  }
}