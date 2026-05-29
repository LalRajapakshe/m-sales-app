class PrinterDevice {
  final String name;
  final String address;

  PrinterDevice({required this.name, required this.address});

  factory PrinterDevice.fromJson(Map<String, dynamic> json) {
    return PrinterDevice(
      name: json['name'],
      address: json['address'],
    );
  }
}
