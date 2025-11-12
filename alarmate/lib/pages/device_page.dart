// pages/device_page.dart
import 'package:alarmate/models/device.dart';
import 'package:flutter/material.dart';

class DevicePage extends StatefulWidget {
  const DevicePage({super.key});
  @override
  State<DevicePage> createState() => _DevicePageState();
}
class _DevicePageState extends State<DevicePage>{
  List<Device> _devices = [
    Device(name: "D0", location: "living room"),
    Device(name: "D1", location: "bedroom"),
    Device(name: "D2", location: "kitchen"),
  ];
  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Device',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Expanded(child:_buildResponsiveAlarmList()),
          
          const SizedBox(height: 16),
          _buildAddDeviceButton(context),
          const Spacer(),
        ],
      ),
    );
  }


  void _toggleActive(int index) {
    setState(() {
      _devices[index].isActive = !_devices[index].isActive;
    });
  }
  Widget _buildResponsiveAlarmList() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;

        if (_devices.isEmpty) {
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
            itemCount: _devices.length,
            itemBuilder: (context, i) => _buildAlarmCard(i),
          );
        } else {
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _devices.length,
            itemBuilder: (context, i) => _buildAlarmCard(i, isList: true),
          );
        }
      },
    );
  }

  Widget _buildAlarmCard(int index, {bool isList = false}) {
    final alarm = _devices[index];
    return Card(
      margin: isList ? const EdgeInsets.only(bottom: 8) : EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: isList ? 1 : 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(
          _devices[index].name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(_devices[index].location,
          style: const TextStyle(color: Colors.black54, fontSize: 14),
        ),
        trailing: Switch(
          value: alarm.isActive,
          onChanged: (_) => _toggleActive(index),
          activeColor: Colors.black,
        ),
      ),
    );
  }


  Widget _buildAddDeviceButton(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.add, size: 32, color: Colors.black54),
      ),
    );
  }
}