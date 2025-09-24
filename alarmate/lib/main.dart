import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:alarmate/pages/alarm_registration.dart';
import 'package:alarmate/models/alarm.dart';
import 'package:alarmate/models/time.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alarm Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AlarmListPage(),
    );
  }
}

class AlarmListPage extends StatefulWidget {
  const AlarmListPage({super.key});
  @override
  State<AlarmListPage> createState() => _AlarmListPageState();
}

class _AlarmListPageState extends State<AlarmListPage> {
  final List<Alarm> _alarms = [];
  int _selectedIndex = 0;

  int _selectedHour = 1;
  int _selectedMinute = 00;
  bool _isPm = true;

  void _addAlarm() async {
    debugPrint("new alarm page");
    final newAlarm = await Navigator.push<Alarm>(
      context,
      MaterialPageRoute(
        builder: (context) => const AlarmRegistrationPage(),
      ),
    );
    if (newAlarm != null) {
      setState(() => _alarms.add(newAlarm));
    }
  }

  void _toggleActive(int index) {
    setState(() {
      _alarms[index].isActive = !_alarms[index].isActive;
    });
  }


  Widget _buildPicker(
      {required List<String> items,
      required int selectedIndex,
      required ValueChanged<int> onSelectedItemChanged}) {
    return Expanded(
      child: CupertinoPicker(
        scrollController: FixedExtentScrollController(initialItem: selectedIndex),
        itemExtent: 40,
        onSelectedItemChanged: onSelectedItemChanged,
        magnification: 1.3,
        useMagnifier: true,
        selectionOverlay: const CupertinoPickerDefaultSelectionOverlay(
          background: Colors.transparent,
        ),
        children: List.generate(items.length, (index) {
          final isSelected = index == selectedIndex;
          return Center(
            child: Text(
              items[index],
              style: TextStyle(
                fontSize: 24,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.black : Colors.grey,
              ),
            ),
          );
        }),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alarm List')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              "Alarms",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Text(
              "Wake up",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ),
          // ✅ Box above alarm list
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
                    selectedIndex: _selectedHour - 1,
                    onSelectedItemChanged: (i) =>
                        setState(() => _selectedHour = i + 1),
                  ),
                  _buildPicker(
                    items: minutes,
                    selectedIndex: _selectedMinute,
                    onSelectedItemChanged: (i) =>
                        setState(() => _selectedMinute = i),
                  ),
                  _buildPicker(
                    items: const ['AM', 'PM'],
                    selectedIndex: _isPm ? 1 : 0,
                    onSelectedItemChanged: (i) =>
                        setState(() => _isPm = (i == 1)),
                  ),
                ],

            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              "Others",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ),
          // ✅ Wrap with Expanded to give ListView a bounded height
          Expanded(
            child: _alarms.isEmpty
                ? const Center(child: Text('There\'s no alarm registered.'))
                : ListView.builder(
                    itemCount: _alarms.length,
                    itemBuilder: (context, index) {
                      final alarm = _alarms[index];
                      return ListTile(
                        title: Text('${alarm.time} - ${alarm.label}'),
                        trailing: Switch(
                          value: alarm.isActive,
                          onChanged: (_) => _toggleActive(index),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAlarm,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.alarm), label: "Alarms"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Calendar"),
          BottomNavigationBarItem(icon: Icon(Icons.devices), label: "Device"),
        ],
      ),
    );
  }

}
