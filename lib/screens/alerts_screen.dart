import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/alert.dart';
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

  // Cargar datos iniciales
  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Cargar alertas directamente
      await _loadAlerts();
    } catch (e) {
      print('ERROR: Error al cargar datos iniciales: $e');
      setState(() {
        _alerts = [];
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
      // Preparar filtros según la lógica de endpoints
      String? deviceFilter = (_selectedDeviceId == 'all') ? null : _selectedDeviceId;
      String? levelFilter = (_selectedLevel == 'all') ? null : _selectedLevel;
      
      // Intentar cargar alertas desde la API
      final alerts = await _alertService.getAlerts(
        deviceId: deviceFilter,
        level: levelFilter,
        limit: _selectedLimit,
      );

      setState(() {
        _alerts = alerts;
        _isLoading = false;
        _isFiltering = false;
      });
      print('DEBUG: Cargadas ${alerts.length} alertas');
    } catch (e) {
      print('ERROR: Error al cargar alertas: $e');
      setState(() {
        _isLoading = false;
        _isFiltering = false;
        _alerts = []; // No usar datos mock, mostrar error
      });
    }
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
    );
  }

  Widget _buildAlertsView() {
    return Column(
      children: [
        // Filtros compactos
        Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filtros en chips horizontales
                Row(
                  children: [
                    Text(
                      'Nivel:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 32,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _levelOptions.length,
                          itemBuilder: (context, index) {
                            final option = _levelOptions[index];
                            final isSelected = option['value'] == _selectedLevel;
                            
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: FilterChip(
                                label: Text(
                                  option['label']!,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isSelected ? Colors.white : AppColors.primaryBlue,
                                  ),
                                ),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _selectedLevel = option['value'] == 'all' ? 'all' : option['value']!;
                                    });
                                    _loadAlerts();
                                  }
                                },
                                selectedColor: AppColors.primaryBlue,
                                backgroundColor: Colors.grey.shade100,
                                checkmarkColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Segunda fila: Límite y botón de actualizar
                Row(
                  children: [
                    Text(
                      'Mostrar:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 32,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _limitOptions.length,
                          itemBuilder: (context, index) {
                            final limit = _limitOptions[index];
                            final isSelected = limit == _selectedLimit;
                            
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: FilterChip(
                                label: Text(
                                  '$limit',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isSelected ? Colors.white : AppColors.primaryBlue,
                                  ),
                                ),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _selectedLimit = limit;
                                    });
                                    _loadAlerts();
                                  }
                                },
                                selectedColor: AppColors.primaryBlue,
                                backgroundColor: Colors.grey.shade100,
                                checkmarkColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    // Botón de actualizar
                    IconButton(
                      onPressed: _isFiltering ? null : _loadAlerts,
                      icon: _isFiltering 
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.primaryBlue,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.refresh, color: AppColors.primaryBlue),
                      tooltip: 'Actualizar alertas',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        // Lista scrolleable de alertas
        Expanded(
          child: _isFiltering
            ? const Center(child: CircularProgressIndicator())
            : _alerts.isEmpty
                ? _buildEmptyAlertsView()
                : _buildAlertsList(),
        ),
      ],
    );
  }

  Widget _buildEmptyAlertsView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off, 
              size: 64, 
              color: Colors.grey[400]
            ),
            const SizedBox(height: 16),
            Text(
              'No hay alertas que mostrar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600]
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Las alertas aparecerán aquí cuando estén disponibles',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14, 
                color: Colors.grey[500]
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertsList() {
    return Container(
      color: Colors.grey[50],
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _alerts.length,
        itemBuilder: (context, index) {
          final alert = _alerts[index];
          return _buildAlertCard(alert);
        },
      ),
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
