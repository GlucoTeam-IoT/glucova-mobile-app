import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/record.dart';

class RecordService {
  final String baseUrl = 'https://glucova-backend-1c16.onrender.com/api/v1';
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<List<Record>> getRecords({int limit = 100, int skip = 0}) async {
    try {
      final token = await _getToken();
      print('DEBUG RecordService: Token retrieved: ${token != null ? 'YES' : 'NO'}');
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final url = '$baseUrl/records?limit=$limit&skip=$skip';
      print('DEBUG RecordService: Making request to: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Tiempo de espera agotado al obtener registros');
        },
      );

      print('DEBUG RecordService: Status code: ${response.statusCode}');
      print('DEBUG RecordService: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // La API devuelve directamente un array, no un objeto con campo 'data'
        if (data is List) {
          final records = data.map((json) {
            try {
              return Record.fromJson(json);
            } catch (e) {
              print('ERROR RecordService: Error parsing record: $e');
              print('ERROR RecordService: Problematic JSON: $json');
              return null;
            }
          }).where((record) => record != null).cast<Record>().toList();
          
          print('DEBUG RecordService: Successfully parsed ${records.length} records');
          return records;
        } else {
          print('ERROR RecordService: Response is not a list: $data');
          throw Exception('Formato de respuesta incorrecto: la respuesta no es una lista');
        }
      } else {
        print('ERROR RecordService: HTTP ${response.statusCode}: ${response.body}');
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('ERROR RecordService: $e');
      rethrow; // Re-lanzar la excepción para que la UI pueda manejarla
    }
  }
}
