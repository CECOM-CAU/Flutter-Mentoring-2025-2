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
  final TextEditingController _labelController = TextEditingController();

  void _saveAlarm() {
    final alarm = Alarm(time: "time", label: "label");
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
