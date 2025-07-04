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
  static const String _emergencyEnabledKey = "emergency_enabled";
  
  // Instancia singleton
  static final EmergencyService _instance = EmergencyService._internal();
  factory EmergencyService() => _instance;
  EmergencyService._internal();

  final ContactService _contactService = ContactService();
  final AlertService _alertService = AlertService();
  Timer? _monitoringTimer;
  bool _isMonitoring = false;

  /// Inicializa el servicio de emergencia
  Future<void> initialize() async {
    print('DEBUG EmergencyService: Iniciando servicio de emergencia simplificado');
    
    // Solicitar permisos necesarios
    await _requestPermissions();
    
    // Verificar si está habilitado
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool(_emergencyEnabledKey) ?? true;
    
    if (isEnabled) {
      await startMonitoring();
    }
    
    print('DEBUG EmergencyService: Servicio de emergencia inicializado');
  }

  /// Solicita permisos necesarios para llamadas de emergencia
  Future<bool> _requestPermissions() async {
    print('DEBUG EmergencyService: Solicitando permisos');
    
    final phoneStatus = await Permission.phone.request();
    final notificationStatus = await Permission.notification.request();
    
    print('DEBUG EmergencyService: Permiso teléfono: $phoneStatus');
    print('DEBUG EmergencyService: Permiso notificación: $notificationStatus');

    return phoneStatus.isGranted;
  }

  /// Inicia el monitoreo de alertas críticas
  Future<void> startMonitoring() async {
    if (_isMonitoring) {
      print('DEBUG EmergencyService: El monitoreo ya está activo');
      return;
    }

    _isMonitoring = true;
    print('DEBUG EmergencyService: Iniciando monitoreo cada 3 minutos');
    
    // Verificar inmediatamente
    await checkForCriticalAlerts();
    
    // Configurar timer para verificar cada 3 minutos
    _monitoringTimer = Timer.periodic(const Duration(minutes: 3), (timer) {
      checkForCriticalAlerts();
    });
  }

  /// Detiene el monitoreo de alertas
  Future<void> stopMonitoring() async {
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
    _isMonitoring = false;
    print('DEBUG EmergencyService: Monitoreo detenido');
  }

  /// Habilita/deshabilita el servicio de emergencia
  Future<void> setEmergencyEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_emergencyEnabledKey, enabled);
    
    if (enabled) {
      await startMonitoring();
    } else {
      await stopMonitoring();
    }
  }

  /// Verifica alertas críticas y activa llamada de emergencia si es necesario
  Future<void> checkForCriticalAlerts() async {
    try {
      print('DEBUG EmergencyService: Verificando alertas críticas');
      
      // Obtener la última verificación
      final prefs = await SharedPreferences.getInstance();
      final lastCheck = prefs.getInt(_lastAlertCheckKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      
      // Solo verificar si han pasado al menos 2 minutos desde la última verificación
      if (now - lastCheck < 120000) { // 2 minutos en milisegundos
        print('DEBUG EmergencyService: Verificación muy reciente, saltando');
        return;
      }
      
      // Obtener alertas recientes (últimas 5)
      final alerts = await _alertService.getAlerts(limit: 5);
      
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
    const criticalLevels = ['critical'];
    
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

  /// Obtiene el estado del servicio de emergencia
  Future<Map<String, dynamic>> getEmergencyStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastCallLog = prefs.getString('last_emergency_call');
      final lastCheck = prefs.getInt(_lastAlertCheckKey) ?? 0;
      final isEnabled = prefs.getBool(_emergencyEnabledKey) ?? true;
      
      return {
        'isActive': _isMonitoring && isEnabled,
        'isEnabled': isEnabled,
        'lastCheck': DateTime.fromMillisecondsSinceEpoch(lastCheck),
        'lastEmergencyCall': lastCallLog != null ? jsonDecode(lastCallLog) : null,
        'hasPhonePermission': await Permission.phone.isGranted,
        'monitoringInterval': '3 minutos',
      };
    } catch (e) {
      return {
        'isActive': false,
        'error': e.toString(),
      };
    }
  }

  /// Fuerza una verificación manual de alertas críticas
  Future<void> manualCheck() async {
    print('DEBUG EmergencyService: Verificación manual solicitada');
    await checkForCriticalAlerts();
  }

  /// Detiene el servicio de emergencia
  Future<void> stop() async {
    await stopMonitoring();
    print('DEBUG EmergencyService: Servicio de emergencia detenido completamente');
  }
}
