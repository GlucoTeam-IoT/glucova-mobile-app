import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/record.dart';

class RecordService {
  final String baseUrl = 'https://glucova-backend-1c16.onrender.com/api/v1';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<List<Record>> getRecords({int limit = 100, int skip = 0}) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/records?limit=$limit&skip=$skip'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('DEBUG RecordService: Status code: ${response.statusCode}');
      print('DEBUG RecordService: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final records = data['data'] as List;
        return records.map((json) => Record.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener registros: ${response.statusCode}');
      }
    } catch (e) {
      print('ERROR RecordService: $e');
      return []; // Retorna una lista vacía en caso de error
    }
  }
}
