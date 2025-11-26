// services/alarm_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alarmate/models/alarm.dart';

class AlarmService extends ChangeNotifier {
  // ----------------------------------------------------------------------
  // Singleton + Private list
  // ----------------------------------------------------------------------
  AlarmService._private();
  static final AlarmService _instance = AlarmService._private();
  
  // 외부에서 이렇게만 가져다 쓰세요!
  static Future<AlarmService> get instance async {
    if (!_instance._isLoaded) {
      await _instance._loadAlarms();
      _instance._isLoaded = true;
    }
    return _instance;
  }

  final List<Alarm> _alarms = [];
  List<Alarm> get alarms => List.unmodifiable(_alarms);

  static const String storageKey = "alarm_list";
  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  // ----------------------------------------------------------------------
  // CRUD (모두 await 보장)
  // ----------------------------------------------------------------------
  Future<void> addAlarm(Alarm alarm) async {
    _alarms.add(alarm);
    await _saveAlarms();
    notifyListeners();
  }

  Future<void> removeAlarm(Alarm alarm) async {
    _alarms.remove(alarm);
    await _saveAlarms();
    notifyListeners();
  }

  Future<void> toggleAlarm(Alarm alarm) async {
    final index = _alarms.indexOf(alarm);
    if (index != -1) {
      _alarms[index] = _alarms[index].copyWith(isActive: !_alarms[index].isActive);
      await _saveAlarms();
      notifyListeners();
    }
  }

  // ----------------------------------------------------------------------
  // Query
  // ----------------------------------------------------------------------
  List<Alarm> alarmsForDay(DateTime day) {
    final dayStr = _fmt(day);
    return _alarms.where((a) => a.date == dayStr || a.date == null).toList();
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // ----------------------------------------------------------------------
  // Persistence
  // ----------------------------------------------------------------------
  Future<void> _saveAlarms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(_alarms.map((a) => a.toJson()).toList());
      final success = await prefs.setString(storageKey, jsonString);
      if (kDebugMode) {
        print('알람 저장 성공: $success | 개수: ${_alarms.length}');
      }
    } catch (e) {
      if (kDebugMode) print('알람 저장 실패: $e');
    }
  }

  Future<void> _loadAlarms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(storageKey);

      if (kDebugMode) {
        print('불러온 알람 데이터: $jsonString');
      }

      if (jsonString == null || jsonString.isEmpty) {
        _alarms.clear();
        notifyListeners();
        return;
      }

      final List<dynamic> list = jsonDecode(jsonString);
      _alarms.clear();
      _alarms.addAll(
        list.map((e) => Alarm.fromJson(e as Map<String, dynamic>)).toList(),
      );

      if (kDebugMode) {
        print('알람 로드 완료: ${_alarms.length}개');
      }
    } catch (e) {
      if (kDebugMode) print('알람 로드 실패: $e');
      _alarms.clear();
    } finally {
      notifyListeners(); // 무조건 호출해서 UI 갱신 보장
    }
  }

  // 테스트용: 모든 데이터 삭제
  Future<void> clearAll() async {
    _alarms.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(storageKey);
    notifyListeners();
  }
}