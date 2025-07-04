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
    try {
      // La API devuelve campos: id, level, user_id, device_id, description, timestamp
      final String idValue = json['id']?.toString() ?? '';
      
      // Manejar timestamp
      DateTime dateValue;
      try {
        final dateStr = json['timestamp']?.toString();
        if (dateStr != null && dateStr.isNotEmpty) {
          // La API devuelve formato: "2025-07-04T05:04:10"
          dateValue = DateTime.parse(dateStr);
        } else {
          dateValue = DateTime.now();
        }
      } catch (e) {
        print('Warning: Could not parse timestamp from JSON, using current time');
        dateValue = DateTime.now();
      }
      
      final String deviceValue = json['device_id']?.toString() ?? 'Unknown Device';
      
      // Extraer nivel de glucosa (campo 'level' en la API)
      int glucoseValue;
      try {
        final glucoseRaw = json['level'] ?? 0;
        if (glucoseRaw is int) {
          glucoseValue = glucoseRaw;
        } else if (glucoseRaw is double) {
          glucoseValue = glucoseRaw.round();
        } else if (glucoseRaw is String) {
          glucoseValue = int.tryParse(glucoseRaw) ?? 0;
        } else {
          glucoseValue = 0;
        }
      } catch (e) {
        print('Warning: Could not parse glucose level, defaulting to 0');
        glucoseValue = 0;
      }
      
      // Determinar estado basado en el nivel de glucosa y la descripción
      String statusValue = 'NORMAL';
      final description = json['description']?.toString().toLowerCase() ?? '';
      
      if (description.contains('critical')) {
        statusValue = 'CRITICAL';
      } else if (description.contains('very low')) {
        statusValue = 'VERY LOW';
      } else if (description.contains('low')) {
        statusValue = 'LOW';
      } else if (description.contains('high')) {
        statusValue = 'HIGH';
      } else if (description.contains('moderate') || description.contains('normal')) {
        statusValue = 'NORMAL';
      } else {
        // Determinar estado basado en el nivel de glucosa
        if (glucoseValue >= 250) {
          statusValue = 'CRITICAL';
        } else if (glucoseValue >= 180) {
          statusValue = 'HIGH';
        } else if (glucoseValue >= 70) {
          statusValue = 'NORMAL';
        } else if (glucoseValue >= 50) {
          statusValue = 'LOW';
        } else {
          statusValue = 'VERY LOW';
        }
      }
      
      // Usar descripción de la API o crear una si no existe
      final String descriptionValue = json['description']?.toString() ?? 
          'Glucose level ${statusValue.toLowerCase()}: $glucoseValue mg/dL';
      
      return Record(
        id: idValue,
        date: dateValue,
        device: deviceValue,
        description: descriptionValue,
        glucoseLevel: glucoseValue,
        status: statusValue,
      );
    } catch (e) {
      print('ERROR parsing Record from JSON: $e');
      print('Problematic JSON: $json');
      rethrow;
    }
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
