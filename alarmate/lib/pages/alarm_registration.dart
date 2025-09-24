import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:alarmate/models/alarm.dart';
import 'package:alarmate/models/time.dart';

class AlarmRegistrationPage extends StatefulWidget {
  const AlarmRegistrationPage({super.key});

  @override
  State<AlarmRegistrationPage> createState() => _AlarmRegistrationPageState();
}

class _AlarmRegistrationPageState extends State<AlarmRegistrationPage> {
  int _selectedHour = 1;
  int _selectedMinute = 00;
  bool _isPm = true;
  String _repeat = 'Once';
  String _label = 'Label';
  String _sound = 'Sound';
  bool _snooze = true;
  bool _editingLabel = false;
  final TextEditingController _labelController = TextEditingController();

  void _saveAlarm() {
    final time =
        '${_selectedHour.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')} ${_isPm ? 'PM' : 'AM'}';
    final alarm = Alarm(time: time, label: _label);
    Navigator.pop(context, alarm);
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

  Widget _buildRow(String label,
      {String? trailing, Widget? trailingWidget, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            trailingWidget ??
                Text(
                  trailing ?? '',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text('AlarmRegistration'),
        backgroundColor: Colors.grey[300],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Time picker with vertical drag
            SizedBox(
              height: 150,
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
            const SizedBox(height: 20),
            Container(
              color: Colors.grey[300],
              margin: const EdgeInsets.all(8),
              child: Column(
                children: [
                  _buildRow('Once', trailing: _repeat, onTap: () {
                    setState(() {
                      _repeat = _repeat == 'Once' ? 'Daily' : 'Once';
                    });
                  }),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Label'),
                        _editingLabel
                            ? Expanded(
                                child: TextField(
                                  controller: _labelController..text = _label,
                                  textAlign: TextAlign.end,
                                  autofocus: true,
                                  onSubmitted: (value) {
                                    setState(() {
                                      _label =
                                          value.trim().isEmpty ? _label : value;
                                      _editingLabel = false;
                                    });
                                  },
                                ),
                              )
                            : InkWell(
                                onTap: () {
                                  setState(() {
                                    _editingLabel = true;
                                  });
                                },
                                child: Text(
                                  _label,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                      ],
                    ),
                  ),
                  _buildRow('Sound', trailing: _sound, onTap: () {
                    setState(() {
                      _sound = _sound == 'Sound' ? 'Beep' : 'Sound';
                    });
                  }),
                  _buildRow(
                    'Snooze',
                    trailingWidget: Switch(
                      value: _snooze,
                      onChanged: (val) => setState(() => _snooze = val),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _saveAlarm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[400],
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
              ),
              child: const Text(
                'save',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
