import 'dart:convert';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/alert.dart';
import '../models/contact.dart';
import 'contact_service.dart';
import 'alert_service.dart';

class EmergencyService {
  static const String _lastAlertCheckKey = "last_alert_check";
  
  // Instancia singleton
  static final EmergencyService _instance = EmergencyService._internal();
  factory EmergencyService() => _instance;
  EmergencyService._internal();

  final ContactService _contactService = ContactService();
  final AlertService _alertService = AlertService();
  
  Timer? _emergencyTimer;
  bool _isInitialized = false;

  /// Inicializa el servicio de emergencia
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    print('DEBUG EmergencyService: Iniciando servicio de emergencia');
    
    // Solicitar permisos necesarios
    await _requestPermissions();
    
    // Iniciar monitoreo periódico
    _startEmergencyMonitoring();
    
    _isInitialized = true;
    print('DEBUG EmergencyService: Servicio de emergencia inicializado');
  }

  /// Solicita permisos necesarios para llamadas de emergencia
  Future<bool> _requestPermissions() async {
    print('DEBUG EmergencyService: Solicitando permisos');
    
    final permissions = [
      Permission.phone,
      Permission.notification,
    ];

    Map<Permission, PermissionStatus> statuses = await permissions.request();
    
    bool allGranted = true;
    for (var permission in permissions) {
      final status = statuses[permission];
      print('DEBUG EmergencyService: Permiso $permission: $status');
      if (status != PermissionStatus.granted) {
        allGranted = false;
      }
    }

    return allGranted;
  }

  /// Inicia el monitoreo periódico usando Timer
  void _startEmergencyMonitoring() {
    // Cancelar timer previo si existe
    _emergencyTimer?.cancel();
    
    // Crear nuevo timer que se ejecute cada 2 minutos
    _emergencyTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      _checkForCriticalAlerts();
    });
    
    // También ejecutar inmediatamente
    _checkForCriticalAlerts();
    
    print('DEBUG EmergencyService: Monitoreo de emergencia iniciado (cada 2 minutos)');
  }

  /// Verifica alertas críticas y activa llamada de emergencia si es necesario
  Future<void> _checkForCriticalAlerts() async {
    try {
      print('DEBUG EmergencyService: Verificando alertas críticas');
      
      // Obtener la última verificación
      final prefs = await SharedPreferences.getInstance();
      final lastCheck = prefs.getInt(_lastAlertCheckKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      
      // Obtener alertas recientes (últimos 5 minutos)
      final alerts = await _alertService.getAlerts(limit: 10);
      
      for (final alert in alerts) {
        // Verificar si es una alerta crítica nueva
        if (_isCriticalAlert(alert) && alert.date.millisecondsSinceEpoch > lastCheck) {
          print('DEBUG EmergencyService: Alerta crítica detectada: ${alert.message}');
          await _triggerEmergencyCall(alert);
          break; // Solo una llamada por verificación
        }
      }
      
      // Actualizar timestamp de última verificación
      await prefs.setInt(_lastAlertCheckKey, now);
      
    } catch (e) {
      print('ERROR EmergencyService: Error verificando alertas críticas: $e');
    }
  }

  /// Determina si una alerta es crítica
  bool _isCriticalAlert(Alert alert) {
    // Niveles críticos que requieren llamada automática
    const criticalLevels = ['critical', 'high'];
    
    // Valores de glucosa que se consideran críticos
    const criticalGlucoseHigh = 300; // mg/dL
    const criticalGlucoseLow = 50;   // mg/dL
    
    // Verificar por nivel
    if (criticalLevels.contains(alert.level.toLowerCase())) {
      return true;
    }
    
    // Verificar por valor de glucosa
    try {
      final glucoseValue = double.parse(alert.glucoseLevel.toString());
      if (glucoseValue >= criticalGlucoseHigh || glucoseValue <= criticalGlucoseLow) {
        return true;
      }
    } catch (e) {
      print('DEBUG EmergencyService: Error parsing glucose value: $e');
    }
    
    return false;
  }

  /// Activa llamada de emergencia automática
  Future<void> _triggerEmergencyCall(Alert alert) async {
    try {
      print('DEBUG EmergencyService: Activando llamada de emergencia');
      
      // Obtener contactos de emergencia
      final contacts = await _contactService.getContacts();
      
      if (contacts.isEmpty) {
        print('DEBUG EmergencyService: No hay contactos de emergencia registrados');
        return;
      }
      
      // Buscar contacto marcado como emergencia o usar el primero
      Contact emergencyContact = contacts.first;
      
      // Intentar encontrar contacto que contenga palabras clave de emergencia
      for (final contact in contacts) {
        final name = contact.name.toLowerCase();
        if (name.contains('emergencia') || 
            name.contains('doctor') || 
            name.contains('médico') ||
            name.contains('hospital')) {
          emergencyContact = contact;
          break;
        }
      }
      
      print('DEBUG EmergencyService: Llamando a contacto de emergencia: ${emergencyContact.name}');
      
      // Realizar llamada automática
      await _makeEmergencyCall(emergencyContact.phone, alert);
      
    } catch (e) {
      print('ERROR EmergencyService: Error en llamada de emergencia: $e');
    }
  }

  /// Realiza la llamada de emergencia automática
  Future<void> _makeEmergencyCall(String phoneNumber, Alert alert) async {
    try {
      // Verificar permisos de llamada
      final hasPhonePermission = await Permission.phone.isGranted;
      if (!hasPhonePermission) {
        print('ERROR EmergencyService: Sin permisos de teléfono para llamada automática');
        return;
      }
      
      // Limpiar número de teléfono
      String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      
      // Crear URI de llamada automática
      final Uri phoneUri = Uri(scheme: 'tel', path: cleanNumber);
      
      print('DEBUG EmergencyService: Realizando llamada automática a: $cleanNumber');
      print('DEBUG EmergencyService: Motivo: ${alert.message}');
      
      // Intentar hacer la llamada
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
        
        // Registrar la llamada de emergencia
        await _logEmergencyCall(phoneNumber, alert);
        
        print('DEBUG EmergencyService: Llamada de emergencia iniciada exitosamente');
      } else {
        print('ERROR EmergencyService: No se puede realizar la llamada a $cleanNumber');
      }
      
    } catch (e) {
      print('ERROR EmergencyService: Error realizando llamada automática: $e');
    }
  }

  /// Registra la llamada de emergencia realizada
  Future<void> _logEmergencyCall(String phoneNumber, Alert alert) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final emergencyLog = {
        'timestamp': DateTime.now().toIso8601String(),
        'phone': phoneNumber,
        'alert_id': alert.id,
        'alert_message': alert.message,
        'glucose_level': alert.glucoseLevel,
        'alert_level': alert.level,
      };
      
      // Guardar log de emergencia
      final logJson = jsonEncode(emergencyLog);
      await prefs.setString('last_emergency_call', logJson);
      
      print('DEBUG EmergencyService: Llamada de emergencia registrada: $logJson');
      
    } catch (e) {
      print('ERROR EmergencyService: Error registrando llamada de emergencia: $e');
    }
  }

  /// Verificación manual de alertas críticas (para testing)
  Future<void> checkForCriticalAlerts() async {
    await _checkForCriticalAlerts();
  }

  /// Obtiene el estado del servicio de emergencia
  Future<Map<String, dynamic>> getEmergencyStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastCallLog = prefs.getString('last_emergency_call');
      final lastCheck = prefs.getInt(_lastAlertCheckKey) ?? 0;
      
      return {
        'isActive': _isInitialized && _emergencyTimer != null && _emergencyTimer!.isActive,
        'lastCheck': DateTime.fromMillisecondsSinceEpoch(lastCheck),
        'lastEmergencyCall': lastCallLog != null ? jsonDecode(lastCallLog) : null,
        'hasPhonePermission': await Permission.phone.isGranted,
        'monitoringInterval': '2 minutos',
      };
    } catch (e) {
      return {
        'isActive': false,
        'error': e.toString(),
      };
    }
  }

  /// Detiene el servicio de emergencia
  Future<void> stop() async {
    _emergencyTimer?.cancel();
    _emergencyTimer = null;
    _isInitialized = false;
    print('DEBUG EmergencyService: Servicio de emergencia detenido');
  }

  /// Reinicia el servicio de emergencia
  Future<void> restart() async {
    await stop();
    await initialize();
  }
}
