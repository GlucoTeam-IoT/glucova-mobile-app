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

      // Construye la URL según los filtros
      String url = '$baseUrl/alerts?limit=$limit&skip=$skip';
      
      // Solo agregar device_id si se especifica
      if (deviceId != null && deviceId.isNotEmpty) {
        url += '&device_id=$deviceId';
      }
      
      // Solo agregar level si se especifica
      if (level != null && level.isNotEmpty) {
        url += '&level=$level';
      }

      print('DEBUG AlertService: Making request to: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Tiempo de espera agotado al obtener alertas');
        },
      );

      print('DEBUG AlertService: Status code: ${response.statusCode}');
      print('DEBUG AlertService: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // La API devuelve directamente un array, no un objeto con campo 'data'
        if (data is List) {
          final alerts = data.map((json) {
            try {
              return Alert.fromJson(json);
            } catch (e) {
              print('ERROR AlertService: Error parsing alert: $e');
              print('ERROR AlertService: Problematic JSON: $json');
              return null;
            }
          }).where((alert) => alert != null).cast<Alert>().toList();
          
          print('DEBUG AlertService: Successfully parsed ${alerts.length} alerts');
          return alerts;
        } else {
          print('ERROR AlertService: Response is not a list: $data');
          throw Exception('Formato de respuesta incorrecto: la respuesta no es una lista');
        }
      } else {
        print('ERROR AlertService: HTTP ${response.statusCode}: ${response.body}');
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('ERROR AlertService: $e');
      rethrow; // Re-lanzar la excepción para que la UI pueda manejarla
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
