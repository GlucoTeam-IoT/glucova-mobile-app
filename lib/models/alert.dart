class Alert {
  final String type;
  final String message;
  final String time;
  final String details;

  Alert({
    required this.type,
    required this.message,
    required this.time,
    required this.details,
  });

  // Mock data for demo purposes
  static List<Alert> mockAlerts() {
    return [
      Alert(
        type: "glucose",
        message: "Glucosa alta",
        time: "Hoy, 8:30 AM",
        details: "180 mg/dL",
      ),
      Alert(
        type: "medication",
        message: "Recordatorio medicación",
        time: "En 30 minutos",
        details: "",
      ),
    ];
  }
}
