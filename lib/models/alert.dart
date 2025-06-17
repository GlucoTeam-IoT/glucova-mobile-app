class Alert {
  final String id;
  final String deviceId;
  final String message;
  final DateTime date;
  final String level; // 'low', 'medium', 'high', 'critical'
  final int glucoseLevel; // Valor numérico del nivel de glucosa

  Alert({
    required this.id,
    required this.deviceId,
    required this.message,
    required this.date,
    required this.level,
    required this.glucoseLevel,
  });

  // Factory constructor para crear un objeto Alert desde JSON
  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      id: json['_id'] ?? '',
      deviceId: json['device_id'] ?? '',
      message: json['message'] ?? '',
      date: json['date'] != null 
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      level: json['level'] ?? 'medium',
      glucoseLevel: json['glucose_level'] ?? 0,
    );
  }

  // Obtener el nombre en español del nivel
  String getLevelName() {
    switch (level.toLowerCase()) {
      case 'critical':
        return 'Crítico';
      case 'high':
        return 'Alto';
      case 'medium':
        return 'Medio';
      case 'low':
        return 'Bajo';
      default:
        return 'Desconocido';
    }
  }

  // Obtener el color según el nivel
  String getLevelColor() {
    switch (level.toLowerCase()) {
      case 'critical':
        return '#ff4d4d'; // Rojo
      case 'high':
        return '#ff9966'; // Naranja
      case 'medium':
        return '#ffcc66'; // Amarillo
      case 'low':
        return '#66ccff'; // Azul claro
      default:
        return '#f7f7f7'; // Gris claro
    }
  }

  // Mock data for demo purposes
  static List<Alert> mockAlerts() {
    return [
      Alert(
        id: '1',
        deviceId: '5ba15a88-6afa-49c7-a848-3edd980c99d1',
        message: 'Glucose level CRITICAL: 400 mg/dL',
        date: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        level: 'critical',
        glucoseLevel: 400,
      ),
      Alert(
        id: '2',
        deviceId: '5ba15a88-6afa-49c7-a848-3edd980c99d1',
        message: 'Glucose level HIGH: 220 mg/dL',
        date: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
        level: 'high',
        glucoseLevel: 220,
      ),
      Alert(
        id: '3',
        deviceId: '5ba15a88-6afa-49c7-a848-3edd980c99d1',
        message: 'Glucose level MEDIUM: 120 mg/dL',
        date: DateTime.now().subtract(const Duration(days: 2)),
        level: 'medium',
        glucoseLevel: 120,
      ),
      Alert(
        id: '4',
        deviceId: '5ba15a88-6afa-49c7-a848-3edd980c99d1',
        message: 'Glucose level LOW: 60 mg/dL',
        date: DateTime.now().subtract(const Duration(days: 3)),
        level: 'low',
        glucoseLevel: 60,
      ),
    ];
  }
}
