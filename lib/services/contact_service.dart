import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/contact.dart';

class ContactService {
  final String baseUrl = 'https://glucova-backend-1c16.onrender.com/api/v1';

  // Obtiene el token JWT de las preferencias compartidas
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Obtiene la lista de contactos desde la API
  Future<List<Contact>> getContacts() async {
    try {
      final token = await _getToken();
      print('DEBUG ContactService: Token retrieved: ${token != null ? 'YES' : 'NO'}');
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/contacts'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('DEBUG ContactService: Status code: ${response.statusCode}');
      print('DEBUG ContactService: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> contactsJson = jsonDecode(response.body);
        return contactsJson.map((json) => Contact.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener contactos: ${response.statusCode}');
      }
    } catch (e) {
      print('ERROR ContactService: $e');
      return []; // Retorna una lista vacía en caso de error
    }
  }

  // Crea un nuevo contacto
  Future<bool> createContact({
    required String name,
    required String email,
    required String phone,
  }) async {
    try {
      final token = await _getToken();
      print('DEBUG ContactService: Creating contact - Token: ${token != null ? 'YES' : 'NO'}');
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final contactData = {
        'name': name,
        'email': email,
        'phone': phone,
      };

      print('DEBUG ContactService: Contact data: $contactData');

      final response = await http.post(
        Uri.parse('$baseUrl/contacts'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(contactData),
      );

      print('DEBUG ContactService: Create status code: ${response.statusCode}');
      print('DEBUG ContactService: Create response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Error al crear contacto: ${response.statusCode}');
      }
    } catch (e) {
      print('ERROR ContactService: $e');
      return false;
    }
  }

  // Elimina un contacto (para futura implementación)
  Future<bool> deleteContact(String contactId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/contacts/$contactId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('DEBUG ContactService: Delete status code: ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('ERROR ContactService: $e');
      return false;
    }
  }

  // NUEVA FUNCIONALIDAD: Hacer una llamada telefónica
  Future<bool> makePhoneCall(String phoneNumber) async {
    try {
      // Limpiar el número de teléfono (remover espacios y caracteres especiales)
      String cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      
      // Crear la URL de llamada
      final Uri phoneUri = Uri(scheme: 'tel', path: cleanedNumber);
      
      print('DEBUG ContactService: Intentando llamar a: $cleanedNumber');
      
      // Verificar si se puede hacer la llamada
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
        return true;
      } else {
        print('ERROR ContactService: No se puede hacer la llamada a $cleanedNumber');
        return false;
      }
    } catch (e) {
      print('ERROR ContactService makePhoneCall: $e');
      return false;
    }
  }

  // NUEVA FUNCIONALIDAD: Enviar un email
  Future<bool> sendEmail(String email) async {
    try {
      // Crear la URL de email
      final Uri emailUri = Uri(scheme: 'mailto', path: email);
      
      print('DEBUG ContactService: Intentando enviar email a: $email');
      
      // Verificar si se puede enviar el email
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
        return true;
      } else {
        print('ERROR ContactService: No se puede enviar email a $email');
        return false;
      }
    } catch (e) {
      print('ERROR ContactService sendEmail: $e');
      return false;
    }
  }
}
