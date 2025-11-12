class Device {
  final String name;
  final String location;
  bool isActive;

  Device({required this.name, required this.location, this.isActive = true});
}