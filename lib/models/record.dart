class Record {
  final String id;
  final DateTime date;
  final String device;
  final String description;
  final int glucoseLevel;
  final String status; // CRITICAL, HIGH, NORMAL, LOW, VERY LOW

  Record({
    required this.id,
    required this.date,
    required this.device,
    required this.description,
    required this.glucoseLevel,
    required this.status,
  });

  factory Record.fromJson(Map<String, dynamic> json) {
    // Extraer valores del JSON con manejo de nulos
    final String idValue = json['_id'] ?? '';
    final String dateStr = json['date'] ?? DateTime.now().toIso8601String();
    final String deviceValue = json['device'] ?? '';
    
    // Crear la descripción basada en el nivel y el estado
    final int glucoseValue = json['glucoseLevel'] ?? 0;
    final String statusValue = json['status'] ?? 'NORMAL';
    final String descriptionValue = 'Glucose level ${statusValue.toLowerCase()}: $glucoseValue mg/dL';
    
    return Record(
      id: idValue,
      date: DateTime.parse(dateStr),
      device: deviceValue,
      description: descriptionValue,
      glucoseLevel: glucoseValue,
      status: statusValue,
    );
  }

  // Crear datos de ejemplo para pruebas
  static List<Record> mockRecords() {
    return [
      Record(
        id: '1',
        date: DateTime.now().subtract(const Duration(days: 1)),
        device: '5ba15a88-6afa-49c7-a848-3edd980c99d1',
        description: 'Glucose level CRITICAL: 400 mg/dL',
        glucoseLevel: 400,
        status: 'CRITICAL',
      ),
      Record(
        id: '2',
        date: DateTime.now().subtract(const Duration(days: 2)),
        device: '5ba15a88-6afa-49c7-a848-3edd980c99d1',
        description: 'Glucose level HIGH: 220 mg/dL',
        glucoseLevel: 220,
        status: 'HIGH',
      ),
      Record(
        id: '3',
        date: DateTime.now().subtract(const Duration(days: 3)),
        device: '5ba15a88-6afa-49c7-a848-3edd980c99d1',
        description: 'Glucose level NORMAL: 100 mg/dL',
        glucoseLevel: 100,
        status: 'NORMAL',
      ),
      Record(
        id: '4',
        date: DateTime.now().subtract(const Duration(days: 3, hours: 5)),
        device: '5ba15a88-6afa-49c7-a848-3edd980c99d1',
        description: 'Glucose level VERY LOW: 40 mg/dL',
        glucoseLevel: 40,
        status: 'VERY LOW',
      ),
    ];
  }
}
