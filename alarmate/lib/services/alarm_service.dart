// services/alarm_service.dart
import 'package:flutter/foundation.dart';
import 'package:alarmate/models/alarm.dart';

class AlarmService extends ChangeNotifier {
  // ----------------------------------------------------------------------
  // 1. Private list + public read-only view
  // ----------------------------------------------------------------------
  final List<Alarm> _alarms = [];

  List<Alarm> get alarms => List.unmodifiable(_alarms);

  // ----------------------------------------------------------------------
  // 2. CRUD helpers
  // ----------------------------------------------------------------------
  void addAlarm(Alarm alarm) {
    _alarms.add(alarm);
    notifyListeners();
  }

  void removeAlarm(Alarm alarm) {
    _alarms.remove(alarm);
    notifyListeners();
  }

  void toggleAlarm(Alarm alarm) {
    final i = _alarms.indexOf(alarm);
    if (i >= 0) {
      _alarms[i].isActive = !_alarms[i].isActive;
      notifyListeners();
    }
  }

  // ----------------------------------------------------------------------
  // 3. Query: alarms that fire on a given day (or every-day alarms)
  // ----------------------------------------------------------------------
  List<Alarm> alarmsForDay(DateTime day) {
    final dayStr = _fmt(day);
    return _alarms.where((a) => a.date == dayStr).toList();
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}