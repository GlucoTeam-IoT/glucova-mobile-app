import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/device.dart';

class DeviceService {
  final String baseUrl = 'https://glucova-backend-1c16.onrender.com/api/v1';

  // Obtiene el token JWT de las preferencias compartidas
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Obtiene la lista de dispositivos desde la API
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

      print('DEBUG DeviceService: Status code: ${response.statusCode}');
      print('DEBUG DeviceService: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final devices = data['data'] as List;
        return devices.map((json) => Device.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener dispositivos: ${response.statusCode}');
      }
    } catch (e) {
      print('ERROR DeviceService: $e');
      return []; // Retorna una lista vacía en caso de error
    }
  }

  // Método para eliminar un dispositivo (para futura implementación)
  Future<bool> deleteDevice(String deviceId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/devices/$deviceId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('ERROR DeviceService: $e');
      return false;
    }
  }
}
