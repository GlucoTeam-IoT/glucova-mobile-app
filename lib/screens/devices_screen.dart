import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/device.dart';
import '../services/device_service.dart';
import '../utils/app_colors.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({Key? key}) : super(key: key);

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  final DeviceService _deviceService = DeviceService();
  List<Device> _devices = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }
  Future<void> _loadDevices() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final devices = await _deviceService.getDevices();
      
      // Si no hay dispositivos (error de API o lista vacía), usar datos de ejemplo
      if (devices.isEmpty) {
        final mockDevices = Device.mockDevices();
        setState(() {
          _devices = mockDevices;
          _isLoading = false;
        });
        return;
      }
      
      setState(() {
        _devices = devices;
        _isLoading = false;
      });
      print('DEBUG: Cargados ${devices.length} dispositivos');
    } catch (e) {
      print('ERROR: Error al cargar dispositivos: $e');
      
      // Usar datos de ejemplo en caso de error
      final mockDevices = Device.mockDevices();
      setState(() {
        _devices = mockDevices;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteDevice(String deviceId) async {
    // En una implementación futura, esto eliminaría el dispositivo
    // Por ahora, solo mostramos un diálogo para una buena experiencia de usuario
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar dispositivo'),
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
  Future<void> _registerDevice() async {
    // Muestra un diálogo con un campo para ingresar el ID del dispositivo
    TextEditingController deviceIdController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registrar nuevo dispositivo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ingresa el ID de tu dispositivo GlucoVa:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: deviceIdController,
              decoration: const InputDecoration(
                labelText: 'ID del Dispositivo',
                border: OutlineInputBorder(),
                hintText: 'ej. 5ba15a88-6afa-49c7-...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _simulateDeviceRegistration(deviceIdController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Registrar'),
          ),
        ],
      ),
    );
  }
  
  void _simulateDeviceRegistration(String deviceId) {
    // Simulamos el registro mostrando un indicador de progreso
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Registrando dispositivo...'),
          ],
        ),
      ),
    );
    
    // Simulamos una demora de 2 segundos para el registro
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Cierra el diálogo de progreso
      
      // Añade el nuevo dispositivo a la lista local
      setState(() {
        _devices.add(Device(
          id: deviceId.isEmpty 
              ? '5ba15a88-6afa-49c7-a848-${DateTime.now().millisecondsSinceEpoch}'
              : deviceId,
          registrationDate: DateTime.now(),
          status: 'Activo',
        ));
      });
      
      // Muestra un mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Dispositivo registrado exitosamente!'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildDevicesView(),
      floatingActionButton: FloatingActionButton(
        onPressed: _registerDevice,
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 4,
        tooltip: 'Registrar dispositivo',
        child: const Icon(Icons.add),
      ),
    );
  }
  Widget _buildDevicesView() {
    return RefreshIndicator(
      onRefresh: _loadDevices,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título y subtítulo
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mis dispositivos',
                    style: const TextStyle(
                      fontSize: 24, 
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    'Administra tus dispositivos de monitoreo',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Dispositivos en formato de tarjetas
              _buildDevicesCards(),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildDevicesCards() {
    if (_devices.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.devices, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No tienes dispositivos registrados',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _registerDevice,
                icon: const Icon(Icons.add),
                label: const Text('Registrar dispositivo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _devices.map((device) {
        final dateFormat = DateFormat('dd/MM/yyyy');
        final timeFormat = DateFormat('hh:mm a');
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [              // ID del dispositivo con icono de eliminar
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.devices, color: AppColors.primaryBlue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ID del Dispositivo',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            device.id.length > 20 
                                ? '${device.id.substring(0, 20)}...'
                                : device.id,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red.shade400, size: 20),
                      onPressed: () => _deleteDevice(device.id),
                      tooltip: 'Eliminar dispositivo',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Fila con fecha, hora y estado
                Row(
                  children: [
                    // Fecha de registro
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Fecha de Registro',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dateFormat.format(device.registrationDate),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Hora
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Hora',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            timeFormat.format(device.registrationDate),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Estado
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Estado',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: device.status.toLowerCase() == 'activo'
                                  ? Colors.green.shade100
                                  : Colors.red.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              device.status,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: device.status.toLowerCase() == 'activo'
                                    ? Colors.green.shade800
                                    : Colors.red.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                  // Ya no necesitamos esta sección de acciones porque movimos el botón de eliminar arriba
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
