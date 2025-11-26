// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/alarm_list_page.dart';
import 'pages/calendar_page.dart';
import 'pages/device_page.dart';
import 'services/alarm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final alarmService = await AlarmService.instance;

  runApp(
    ChangeNotifierProvider<AlarmService>(
      create: (_) => alarmService,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const AlarmListPage(),
    const CalendarPage(),
    const DevicePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alarmate',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFE0E0E0),
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Alarmate'),
        ),
        body: _pages[_selectedIndex],
        floatingActionButton: _selectedIndex == 2
            ? FloatingActionButton(
                backgroundColor: Colors.grey[400],
                onPressed: () {
                  // Device 추가 로직 (임시)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Add new device')),
                  );
                },
                child: const Icon(Icons.add, color: Colors.black),
              )
            : null,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.alarm), label: "Alarms"),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Calendar"),
            BottomNavigationBarItem(icon: Icon(Icons.devices), label: "Device"),
          ],
        ),
      ),
    );
  }
}