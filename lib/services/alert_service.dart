import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/alert.dart';
import '../models/device.dart';

class AlertService {
  final String baseUrl = 'https://glucova-backend-1c16.onrender.com/api/v1';
  // Obtiene el token JWT de las preferencias compartidas
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Obtiene la lista de alertas con filtros opcionales
  Future<List<Alert>> getAlerts({
    String? deviceId,
    String? level,
    int limit = 100,
    int skip = 0,
  }) async {    try {
      final token = await _getToken();
      print('DEBUG AlertService: Token retrieved: ${token != null ? 'YES' : 'NO'}');
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      // Construye la URL con los parámetros de consulta
      String url = '$baseUrl/alerts?limit=$limit&skip=$skip';
      if (deviceId != null && deviceId.isNotEmpty && deviceId != 'all') {
        url += '&device_id=$deviceId';
      }
      if (level != null && level.isNotEmpty && level != 'all') {
        url += '&level=$level';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('DEBUG AlertService: URL: $url');
      print('DEBUG AlertService: Status code: ${response.statusCode}');
      print('DEBUG AlertService: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final alerts = data['data'] as List;
        return alerts.map((json) => Alert.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener alertas: ${response.statusCode}');
      }
    } catch (e) {
      print('ERROR AlertService: $e');
      return []; // Retorna una lista vacía en caso de error
    }
  }

  // Obtiene la lista de dispositivos para filtrar
  Future<List<Device>> getDevices() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/devices'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final devices = data['data'] as List;
        return devices.map((json) => Device.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener dispositivos: ${response.statusCode}');
      }
    } catch (e) {
      print('ERROR AlertService: $e');
      return []; // Retorna una lista vacía en caso de error
    }
  }
}
