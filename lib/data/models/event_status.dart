enum EventStatus { planning, occurring, done }

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
}
