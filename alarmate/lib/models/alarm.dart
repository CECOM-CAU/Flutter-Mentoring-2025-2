class Alarm {
  final String time;
  final String? date;
  final String label;
  bool isActive;

  Alarm({required this.time, required this.label, this.isActive = true, this.date});
}
