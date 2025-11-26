// models/alarm.dart
class Alarm {
  final String time;
  final String? date;
  final String label;
  bool isActive;

  Alarm({
    required this.time,
    required this.label,
    this.isActive = true,
    this.date,
  });

  // JSON → Alarm
  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      time: json["time"] as String,
      date: json["date"] as String?,
      label: json["label"] as String,
      isActive: json["isActive"] as bool? ?? true,
    );
  }

  // Alarm → JSON
  Map<String, dynamic> toJson() {
    return {
      "time": time,
      "date": date,
      "label": label,
      "isActive": isActive,
    };
  }

  // copyWith 없이도 안전하게 새 인스턴스 생성 (필수!)
  Alarm copyWith({bool? isActive}) {
    return Alarm(
      time: time,
      date: date,
      label: label,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Alarm &&
          runtimeType == other.runtimeType &&
          time == other.time &&
          date == other.date &&
          label == other.label &&
          isActive == other.isActive;

  @override
  int get hashCode => Object.hash(time, date, label, isActive);
}