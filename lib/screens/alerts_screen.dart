import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/alert.dart';
import '../models/device.dart';
import '../services/alert_service.dart';
import '../utils/app_colors.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({Key? key}) : super(key: key);

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final AlertService _alertService = AlertService();
  List<Alert> _alerts = [];
  List<Device> _devices = [];
  bool _isLoading = false;
  bool _isFiltering = false;

  // Filtros
  String _selectedDeviceId = 'all';
  String _selectedLevel = 'all';
  int _selectedLimit = 100;

  // Opciones de filtro
  final List<int> _limitOptions = [10, 25, 50, 100];
  final List<Map<String, String>> _levelOptions = [
    {'value': 'all', 'label': 'Todos los niveles'},
    {'value': 'low', 'label': 'Bajo'},
    {'value': 'medium', 'label': 'Medio'},
    {'value': 'high', 'label': 'Alto'},
    {'value': 'critical', 'label': 'Crítico'},
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  // Cargar datos iniciales (dispositivos y alertas)
  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Cargar dispositivos para el filtro
      final devices = await _alertService.getDevices();
      if (devices.isNotEmpty) {
        setState(() {
          _devices = devices;
        });
      } else {
        // Usar dispositivos de ejemplo si la API no retorna datos
        setState(() {
          _devices = Device.mockDevices();
        });
      }

      // Cargar alertas
      await _loadAlerts();
    } catch (e) {
      print('ERROR: Error al cargar datos iniciales: $e');
      // Usar datos de ejemplo en caso de error
      setState(() {
        _devices = Device.mockDevices();
        _alerts = Alert.mockAlerts();
        _isLoading = false;
      });
    }
  }

  // Cargar alertas con los filtros aplicados
  Future<void> _loadAlerts() async {
    setState(() {
      _isFiltering = true;
    });

    try {
      // Intentar cargar alertas desde la API
      final alerts = await _alertService.getAlerts(
        deviceId: _selectedDeviceId == 'all' ? null : _selectedDeviceId,
        level: _selectedLevel == 'all' ? null : _selectedLevel,
        limit: _selectedLimit,
      );

      // Si no se obtienen alertas, usar datos de ejemplo
      if (alerts.isEmpty) {
        setState(() {
          _alerts = Alert.mockAlerts();
          _isLoading = false;
          _isFiltering = false;
        });
        return;
      }

      setState(() {
        _alerts = alerts;
        _isLoading = false;
        _isFiltering = false;
      });
      print('DEBUG: Cargadas ${alerts.length} alertas');
    } catch (e) {
      print('ERROR: Error al cargar alertas: $e');
      // Usar alertas de ejemplo en caso de error
      setState(() {
        _alerts = Alert.mockAlerts();
        _isLoading = false;
        _isFiltering = false;
      });
    }
  }

  // Método para aplicar filtros
  void _applyFilters() {
    _loadAlerts();
  }

  // Crear nueva alerta (funcionalidad a implementar en el futuro)
  void _createNewAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crear alerta'),
        content: const Text('Esta funcionalidad será implementada próximamente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  // Eliminar una alerta (funcionalidad a implementar en el futuro)
  void _deleteAlert(String alertId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar alerta'),
        content: const Text('Esta funcionalidad será implementada próximamente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAlerts,
              child: _buildAlertsView(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewAlert,
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildAlertsView() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título y subtítulo
            Text(
              'Alertas',
              style: const TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            Text(
              'Administra tus alertas de monitoreo',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            
            // Sección de filtros
            _buildFiltersSection(),
            const SizedBox(height: 16),
            
            // Lista de alertas
            _isFiltering
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _alerts.isEmpty
                    ? _buildEmptyAlertsView()
                    : _buildAlertsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtrar alertas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),
            
            // Filtro de dispositivo
            const Text('Dispositivo'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedDeviceId,
                  isExpanded: true,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedDeviceId = value;
                      });
                    }
                  },
                  items: [
                    const DropdownMenuItem<String>(
                      value: 'all',
                      child: Text('Todos los dispositivos'),
                    ),
                    ..._devices.map((device) {
                      // Mostrar una versión truncada del ID
                      String shortId = device.id.length > 15
                          ? '${device.id.substring(0, 15)}...'
                          : device.id;
                      
                      return DropdownMenuItem<String>(
                        value: device.id,
                        child: Text(shortId),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Filtro de nivel
            const Text('Nivel'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedLevel,
                  isExpanded: true,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedLevel = value;
                      });
                    }
                  },
                  items: _levelOptions.map((level) {
                    return DropdownMenuItem<String>(
                      value: level['value'],
                      child: Text(level['label']!),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Filtro de límite
            const Text('Mostrar'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _selectedLimit,
                  isExpanded: true,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedLimit = value;
                      });
                    }
                  },
                  items: _limitOptions.map((limit) {
                    return DropdownMenuItem<int>(
                      value: limit,
                      child: Text('$limit alertas'),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Botón para aplicar filtros
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Aplicar filtros'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyAlertsView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No hay alertas que mostrar',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Prueba a cambiar los filtros o a crear una nueva alerta',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _alerts.length,
      itemBuilder: (context, index) {
        final alert = _alerts[index];
        return _buildAlertCard(alert);
      },
    );
  }

  Widget _buildAlertCard(Alert alert) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm a');
    
    // Color según el nivel
    Color levelColor;
    switch (alert.level.toLowerCase()) {
      case 'critical':
        levelColor = Colors.red.shade100;
        break;
      case 'high':
        levelColor = Colors.orange.shade100;
        break;
      case 'medium':
        levelColor = Colors.yellow.shade100;
        break;
      case 'low':
        levelColor = Colors.blue.shade100;
        break;
      default:
        levelColor = Colors.grey.shade100;
    }

    // Color del texto del nivel
    Color levelTextColor;
    switch (alert.level.toLowerCase()) {
      case 'critical':
        levelTextColor = Colors.red;
        break;
      case 'high':
        levelTextColor = Colors.orange[700]!;
        break;
      case 'medium':
        levelTextColor = Colors.amber[700]!;
        break;
      case 'low':
        levelTextColor = Colors.blue;
        break;
      default:
        levelTextColor = Colors.grey[700]!;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nivel de alerta
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: levelColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    alert.getLevelName(),
                    style: TextStyle(
                      color: levelTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                // Botón de eliminar
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red[300], size: 20),
                  onPressed: () => _deleteAlert(alert.id),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Mensaje de la alerta
            Text(
              alert.message,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            
            // Información adicional
            Row(
              children: [
                // Dispositivo (versión truncada)
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.devices, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          alert.deviceId.length > 15 
                              ? '${alert.deviceId.substring(0, 15)}...' 
                              : alert.deviceId,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Fecha
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      dateFormat.format(alert.date),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                
                // Hora
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      timeFormat.format(alert.date),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
