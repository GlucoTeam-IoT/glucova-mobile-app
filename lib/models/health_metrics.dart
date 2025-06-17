class HealthMetrics {
  final double glucose;
  final String glucoseTrend;
  final String bloodPressure;
  final String bloodPressureStatus;
  final double weight;
  final String weightTrend;
  final double bmi;
  final String bmiStatus;
  final String lastMeasurement;

  HealthMetrics({
    required this.glucose,
    required this.glucoseTrend,
    required this.bloodPressure,
    required this.bloodPressureStatus,
    required this.weight,
    required this.weightTrend,
    required this.bmi,
    required this.bmiStatus,
    required this.lastMeasurement,
  });

  // Mock data constructor for demo purposes
  factory HealthMetrics.mock() {
    return HealthMetrics(
      glucose: 120,
      glucoseTrend: "2% vs ayer",
      bloodPressure: "120/80",
      bloodPressureStatus: "Normal",
      weight: 68,
      weightTrend: "1% vs mes",
      bmi: 24.5,
      bmiStatus: "Saludable",
      lastMeasurement: "8:30 AM",
    );
  }
}
