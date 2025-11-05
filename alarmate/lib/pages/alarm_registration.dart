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
  int _selectedMinute = 0;
  bool _isPm = true;
  String _repeat = 'Once';
  String _label = 'Label';
  String _sound = 'Sound';
  bool _snooze = true;
  bool _editingLabel = false;
  final TextEditingController _labelController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 초기값 설정 (예: 오전 1시 → 실제로는 기본값으로 7:00 AM 등 설정 가능)
    _selectedHour = 7;
    _isPm = false;
    _selectedMinute = 0;
  }

  void _saveAlarm() {
    // 12시간제 → 24시간제로 변환
    int hour24 = _selectedHour % 12;
    if (_isPm) hour24 += 12;
    if (hour24 == 12 && !_isPm) hour24 = 0; // 12 AM → 00
    if (hour24 == 0 && _isPm) hour24 = 12;  // 12 PM → 12

    final time =
        '${hour24.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')}';
    final alarm = Alarm(
      time: time,
      label: _label,
      isActive: true,
    );
    Navigator.pop(context, alarm);
  }

  Widget _buildPicker({
    required List<String> items,
    required int selectedIndex,
    required ValueChanged<int> onSelectedItemChanged,
  }) {
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
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final value = entry.value;
          final isSelected = index == selectedIndex;
          return Center(
            child: Text(
              value,
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

  Widget _buildRow(
    String label, {
    String? trailing,
    Widget? trailingWidget,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 16)),
            trailingWidget ??
                Text(
                  trailing ?? '',
                  style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87),
                ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 반응형: 화면 너비에 따라 패딩 조정
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth > 600 ? 32.0 : 16.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Alarm Registration'),
        backgroundColor: Colors.grey[300],
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _saveAlarm,
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // 시간 피커
            SizedBox(
              height: 160,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPicker(
                    items: hours,
                    selectedIndex: _selectedHour % 12 == 0 ? 11 : (_selectedHour % 12) - 1,
                    onSelectedItemChanged: (i) {
                      final newHour = (i + 1) % 12;
                      setState(() {
                        _selectedHour = _isPm
                            ? (newHour == 0 ? 12 : newHour) + 12
                            : (newHour == 0 ? 12 : newHour);
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildPicker(
                    items: minutes,
                    selectedIndex: _selectedMinute,
                    onSelectedItemChanged: (i) => setState(() => _selectedMinute = i),
                  ),
                  const SizedBox(width: 8),
                  _buildPicker(
                    items: const ['AM', 'PM'],
                    selectedIndex: _isPm ? 1 : 0,
                    onSelectedItemChanged: (i) => setState(() => _isPm = i == 1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 설정 항목들
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildRow('Repeat', trailing: _repeat, onTap: () {
                    setState(() {
                      _repeat = _repeat == 'Once' ? 'Daily' : 'Once';
                    });
                  }),
                  Divider(height: 1, thickness: 0.5, color: Colors.grey[400]),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Label', style: TextStyle(fontSize: 16)),
                        _editingLabel
                            ? Expanded(
                                child: TextField(
                                  controller: _labelController..text = _label,
                                  textAlign: TextAlign.end,
                                  autofocus: true,
                                  style: const TextStyle(fontSize: 16),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                  onSubmitted: (value) {
                                    setState(() {
                                      _label = value.trim().isEmpty ? 'Label' : value;
                                      _editingLabel = false;
                                    });
                                  },
                                ),
                              )
                            : GestureDetector(
                                onTap: () => setState(() => _editingLabel = true),
                                child: Text(
                                  _label,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                  Divider(height: 1, thickness: 0.5, color: Colors.grey[400]),
                  _buildRow('Sound', trailing: _sound, onTap: () {
                    setState(() {
                      _sound = _sound == 'Sound' ? 'Beep' : 'Sound';
                    });
                  }),
                  Divider(height: 1, thickness: 0.5, color: Colors.grey[400]),
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

            // 저장 버튼 (반응형 너비)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveAlarm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[400],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Alarm',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }
}