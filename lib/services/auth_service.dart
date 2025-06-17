import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static const String baseUrl = 'https://glucova-backend-1c16.onrender.com/api/v1/users';
  static const String signInEndpoint = '$baseUrl/sign-in';
  static const String signUpEndpoint = '$baseUrl/sign-up';
  // Almacenar token JWT
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    print('DEBUG AuthService: Token saved successfully');
  }
  // Obtener token JWT almacenado
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    print('DEBUG AuthService: Token retrieved: ${token != null ? 'YES' : 'NO'}');
    return token;
  }// Iniciar sesión
  Future<User> signIn(String email, String password) async {
    try {
      print('Intentando conectar a: $signInEndpoint');
      print('Datos: email=$email, password=${password.substring(0, 2)}...');
      
      final client = http.Client();
      final response = await client.post(
        Uri.parse(signInEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          client.close();
          throw Exception('Tiempo de espera agotado. El servidor está tardando en responder.');
        },
      );
      
      print('Respuesta recibida. Código: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print('Datos recibidos: $data');
        
        // El token viene como 'access_token' en la respuesta
        final String token = data['access_token'] ?? '';
        
        if (token.isNotEmpty) {
          await _saveToken(token);
          
          // Extraer el ID del usuario del token JWT (si es posible)
          String userId = '';
          try {
            // Dividir el token en sus partes
            final parts = token.split('.');
            if (parts.length > 1) {
              // Decodificar la parte del payload
              final payload = parts[1];
              final normalized = base64Url.normalize(payload);
              final decodedPayload = utf8.decode(base64Url.decode(normalized));
              final payloadData = json.decode(decodedPayload);
              
              // Obtener el sub (subject) que normalmente es el ID del usuario
              userId = payloadData['sub'] ?? '';
            }
          } catch (e) {
            print('No se pudo extraer ID del token: $e');
          }
          
          // Crear un objeto de usuario con la información disponible
          return User(
            id: userId,
            email: email,
            name: '',  // El backend no proporciona el nombre
            token: token,
          );
        } else {
          throw Exception('Access token no recibido');
        }
      } else {
        print('Error de respuesta: ${response.body}');
        try {
          final error = json.decode(response.body);
          throw Exception(error['message'] ?? 'Error al iniciar sesión');
        } catch (e) {
          throw Exception('Error al iniciar sesión. Código: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error de conexión: $e');
      throw Exception('Error de conexión: $e');
    }
  }  // Registrar usuario
  Future<User> signUp(String email, String password) async {
    try {
      print('DEBUG SIGNUP: Intentando conectar a: $signUpEndpoint');
      print('DEBUG SIGNUP: Datos: email=$email, password=${password.substring(0, 2)}...');
      
      final client = http.Client();
      final response = await client.post(
        Uri.parse(signUpEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          client.close();
          throw Exception('Tiempo de espera agotado. El servidor está tardando en responder.');
        },
      );

      print('DEBUG SIGNUP: Respuesta recibida. Código: ${response.statusCode}');
      
      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        print('DEBUG SIGNUP: Datos recibidos: $data');
        
        // NOTA: La respuesta de registro es diferente de la de login
        // El registro devuelve los datos del usuario pero NO el token
        
        // Después del registro, intentamos hacer login automáticamente
        try {
          print('DEBUG SIGNUP: Realizando login automático después del registro');
          return await signIn(email, password);
        } catch (e) {
          print('DEBUG SIGNUP: Error en login automático: $e');
          
          // Si el login falla, devolvemos un usuario con los datos del registro
          // pero sin token (el usuario tendrá que hacer login manualmente)
          final String userId = data['id'] ?? '';
          
          return User(
            id: userId,
            email: email,
            name: 'Usuario', // Usamos un valor por defecto para evitar problemas de null check
            token: '', // Sin token
          );
        }
      } else {
        print('ERROR SIGNUP: Error de respuesta: ${response.body}');
        try {
          final error = json.decode(response.body);
          throw Exception(error['message'] ?? 'Error al registrar usuario');
        } catch (e) {
          throw Exception('Error al registrar usuario. Código: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('ERROR SIGNUP: Error de conexión: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Verificar si el usuario está autenticado
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }  // Obtener el usuario actual desde el token almacenado
  Future<User?> getCurrentUser() async {
    print('DEBUG AUTH: Intentando obtener usuario actual');
    final token = await getToken();
    
    if (token == null || token.isEmpty) {
      print('DEBUG AUTH: No hay token almacenado');
      return null;
    }
    
    print('DEBUG AUTH: Token encontrado: ${token.substring(0, 20)}...');
    String userId = '';
    
    try {
      // Extraer la información del token JWT
      final parts = token.split('.');
      if (parts.length > 1) {
        final payload = parts[1];
        final normalized = base64Url.normalize(payload);
        final decodedPayload = utf8.decode(base64Url.decode(normalized));
        final payloadData = json.decode(decodedPayload);
        
        userId = payloadData['sub'] ?? '';
        print('DEBUG AUTH: ID extraído del token: $userId');
        
        // Como el token no contiene el email ni el nombre, solo podemos usar el ID
        final user = User(
          id: userId,
          email: 'usuario@glucova.com',  // Usamos un valor por defecto
          name: 'Usuario',  // Usamos un valor por defecto en lugar de null
          token: token,
        );
        print('DEBUG AUTH: Usuario creado correctamente: ${user.id}');
        return user;
      } else {
        print('DEBUG AUTH: El token no tiene el formato correcto');
      }
    } catch (e) {
      print('ERROR AUTH: Error al decodificar el token: $e');
      return null;
    }
    
    print('DEBUG AUTH: No se pudo extraer información del token');
    return null;
  }
}
