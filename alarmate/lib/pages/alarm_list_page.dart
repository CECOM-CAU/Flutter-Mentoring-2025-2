// pages/alarm_list_page.dart
import 'dart:developer';

import 'package:alarmate/services/alarm_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'alarm_registration.dart';
import '../models/alarm.dart';
import '../models/time.dart';

class AlarmListPage extends StatefulWidget {
  const AlarmListPage({super.key});

  @override
  State<AlarmListPage> createState() => _AlarmListPageState();
}

class _AlarmListPageState extends State<AlarmListPage> {

  // For "Wake up" preview box
  int _nextHour = 7;
  int _nextMinute = 0;
  bool _isPm = false;

  @override
  void initState() {
    super.initState();
    // Default wake-up time: 7:00 AM
    _updateNextAlarm();
  }

  void _updateNextAlarm() {
    final now = DateTime.now();
    final Service = Provider.of<AlarmService>(context, listen: false);
    final activeAlarms = Service.alarms.where((a) => a.isActive).toList();

    if (activeAlarms.isEmpty) {
      _nextHour = 7;
      _nextMinute = 0;
      _isPm = false;
      return;
    }

    // Sort by time
    activeAlarms.sort((a, b) {
      final aTime = _parseTime(a.time);
      final bTime = _parseTime(b.time);
      return aTime.compareTo(bTime);
    });

    // Find next alarm (simplified: first in list)
    final next = activeAlarms.first;
    final parts = next.time.split(':');
    _nextHour = int.parse(parts[0]);
    _nextMinute = int.parse(parts[1]);
    _isPm = _nextHour >= 12;
    if (_nextHour > 12) _nextHour -= 12;
    if (_nextHour == 0) _nextHour = 12;
  }

  DateTime _parseTime(String time) {
    final parts = time.split(':');
    return DateTime(0, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
  }

  void _addAlarm() async {
    final newAlarm = await Navigator.push<Alarm>(
      context,
      MaterialPageRoute(builder: (_) => const AlarmRegistrationPage()),
    );
  }

  void _toggleActive(Alarm alarm) {
    Provider.of<AlarmService>(context,listen: false).toggleAlarm(alarm);
  }

  Widget _buildPicker({
    required List<String> items,
    required int selectedIndex,
    required ValueChanged<int> onSelectedItemChanged,
  }) {
    return Expanded(
      child: CupertinoPicker(
        itemExtent: 40,
        magnification: 1.3,
        useMagnifier: true,
        scrollController: FixedExtentScrollController(initialItem: selectedIndex),
        onSelectedItemChanged: onSelectedItemChanged,
        selectionOverlay: const CupertinoPickerDefaultSelectionOverlay(
          background: Colors.transparent,
        ),
        children: items.asMap().entries.map((e) {
          final isSelected = e.key == selectedIndex;
          return Center(
            child: Text(
              e.value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.black : Colors.grey,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildResponsiveAlarmList() {
    return Consumer<AlarmService>(
        builder: (context, service,_) {
        final alarms = service.alarms;
        return LayoutBuilder(builder: (context, constraints){          
          final isWide = constraints.maxWidth > 600;
          if (alarms.isEmpty) {
            return const Center(
              child: Text("There's no alarm registered."),
            );
          }

          if (isWide) {
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: alarms.length,
              itemBuilder: (_, i) => _buildAlarmCard(alarms[i]),
            );
          } else {
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: alarms.length,
              itemBuilder: (_, i) => _buildAlarmCard(alarms[i], isList: true),
            );
          }
          },
        );
      }
    );
  }

  Widget _buildAlarmCard(Alarm alarm, {bool isList = false}) {
    final time12 = _to12Hour(alarm.time);

    return Card(
      margin: isList ? const EdgeInsets.only(bottom: 8) : EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: isList ? 1 : 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(
          '${time12['hour']}:${time12['minute']} ${time12['period']} - ${alarm.label}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(alarm.date == null ? "" : alarm.date.toString(), 
          style: const TextStyle(color: Colors.black54, fontSize: 14),
        ),
        trailing: Switch(
          value: alarm.isActive,
          onChanged: (_) => _toggleActive(alarm),
          activeColor: Colors.black,
        ),
      ),
    );
  }

  Map<String, String> _to12Hour(String time24) {
    final parts = time24.split(':');
    var hour = int.parse(parts[0]);
    final minute = parts[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;
    return {
      'hour': hour.toString().padLeft(2, '0'),
      'minute': minute,
      'period': period,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text("Alarms", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Text("Wake up", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          ),

          // Wake up preview box
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPicker(
                  items: hours,
                  selectedIndex: _nextHour % 12 == 0 ? 11 : (_nextHour % 12) - 1,
                  onSelectedItemChanged: (_) {}, // read-only
                ),
                _buildPicker(
                  items: minutes,
                  selectedIndex: _nextMinute,
                  onSelectedItemChanged: (_) {},
                ),
                _buildPicker(
                  items: const ['AM', 'PM'],
                  selectedIndex: _isPm ? 1 : 0,
                  onSelectedItemChanged: (_) {},
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text("Others", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          ),

          // Responsive List/Grid
          Expanded(child: _buildResponsiveAlarmList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey[400],
        onPressed: _addAlarm,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}