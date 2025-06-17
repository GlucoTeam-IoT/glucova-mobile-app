class Device {
  final String id;
  final DateTime registrationDate;
  final String status;

  Device({
    required this.id,
    required this.registrationDate,
    required this.status,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['_id'] ?? json['id'] ?? '',
      registrationDate: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      status: json['status'] ?? 'Inactivo',
    );
  }

  // Datos de ejemplo para pruebas
  static List<Device> mockDevices() {
    return [
      Device(
        id: '5ba15a88-6afa-49c7-a848-3edd980c99d1',
        registrationDate: DateTime.now().subtract(const Duration(days: 10)),
        status: 'Activo',
      ),
    ];
  }
}
