import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/record.dart';
import '../services/record_service.dart';
import '../utils/app_colors.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final RecordService _recordService = RecordService();
  List<Record> _records = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  
  // Para el filtro de registros a mostrar
  int _limitValue = 100;
  final List<int> _availableLimits = [10, 25, 50, 100];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }  Future<void> _loadRecords() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      print('DEBUG: Cargando registros con límite: $_limitValue');
      final records = await _recordService.getRecords(limit: _limitValue);
      
      setState(() {
        _records = records;
        _isLoading = false;
      });
      
      print('DEBUG: Cargados ${records.length} registros desde la API');
      
      // Si no hay registros desde la API, mostrar mensaje pero no usar mocks
      if (records.isEmpty) {
        print('DEBUG: No se encontraron registros en la API');
      }
      
    } catch (e) {
      print('ERROR: Error al cargar registros: $e');
      
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Error al cargar registros desde el servidor';
        _records = []; // No usar datos mock, mostrar error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? _buildErrorView()
              : _buildHistoryView(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            'Error al cargar los datos',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(_errorMessage),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadRecords,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryView() {
    return Column(
      children: [
        // Filtros ultra compactos con chips
        Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Filtros con chips horizontales
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            'Mostrar:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 32,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _availableLimits.length,
                                itemBuilder: (context, index) {
                                  final limit = _availableLimits[index];
                                  final isSelected = limit == _limitValue;
                                  
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: FilterChip(
                                      label: Text(
                                        '$limit',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isSelected ? Colors.white : AppColors.primaryBlue,
                                        ),
                                      ),
                                      selected: isSelected,
                                      onSelected: (selected) {
                                        if (selected && limit != _limitValue) {
                                          setState(() {
                                            _limitValue = limit;
                                          });
                                          _loadRecords();
                                        }
                                      },
                                      selectedColor: AppColors.primaryBlue,
                                      backgroundColor: Colors.grey.shade100,
                                      checkmarkColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Botón de actualizar compacto
                    IconButton(
                      onPressed: _isLoading ? null : _loadRecords,
                      icon: _isLoading 
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.primaryBlue,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.refresh, color: AppColors.primaryBlue),
                      tooltip: 'Actualizar registros',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        // Lista scrolleable de registros
        Expanded(
          child: _buildRecordsList(),
        ),
      ],
    );
  }

  Widget _buildRecordsList() {
    if (_records.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No hay registros disponibles',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Los registros aparecerán aquí cuando estén disponibles',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: Colors.grey[50],
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _records.length,
        itemBuilder: (context, index) {
          final record = _records[index];
          return _buildRecordCard(record);
        },
      ),
    );
  }

  Widget _buildRecordCard(Record record) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm a');
    
    // Color según el nivel de glucosa
    Color statusColor;
    Color statusBackgroundColor;
    IconData statusIcon;
    
    switch (record.status.toUpperCase()) {
      case 'CRITICAL':
        statusColor = Colors.red.shade700;
        statusBackgroundColor = Colors.red.shade50;
        statusIcon = Icons.warning;
        break;
      case 'HIGH':
        statusColor = Colors.orange.shade700;
        statusBackgroundColor = Colors.orange.shade50;
        statusIcon = Icons.trending_up;
        break;
      case 'NORMAL':
        statusColor = Colors.green.shade700;
        statusBackgroundColor = Colors.green.shade50;
        statusIcon = Icons.check_circle;
        break;
      case 'LOW':
        statusColor = Colors.blue.shade700;
        statusBackgroundColor = Colors.blue.shade50;
        statusIcon = Icons.trending_down;
        break;
      case 'VERY LOW':
        statusColor = Colors.purple.shade700;
        statusBackgroundColor = Colors.purple.shade50;
        statusIcon = Icons.keyboard_double_arrow_down;
        break;
      default:
        statusColor = Colors.grey.shade700;
        statusBackgroundColor = Colors.grey.shade50;
        statusIcon = Icons.help;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header con fecha y hora
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dateFormat.format(record.date),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 18,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      timeFormat.format(record.date),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Nivel de glucosa principal
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: statusBackgroundColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    statusIcon,
                    color: statusColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    children: [
                      Text(
                        '${record.glucoseLevel} mg/dL',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                      Text(
                        record.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
