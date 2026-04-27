import 'package:flutter/material.dart';
import 'package:t5/theme/palette.dart';
import '../data/models/event_status.dart';

Color getEventStatusColor(EventStatus status) {
  switch (status) {
    case EventStatus.planning:
      return Palette.statusPlanning;

    case EventStatus.occurring:
      return Palette.statusOccurring;

    case EventStatus.done:
      return Palette.statusDone;
  }
}
