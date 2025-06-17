import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import '../models/health_metrics.dart';
import '../models/alert.dart';
import '../services/auth_service.dart';
import 'history_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final HealthMetrics _metrics = HealthMetrics.mock();
  final List<Alert> _alerts = Alert.mockAlerts();
  String _userName = "Usuario";
  String _userEmail = "";
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  Future<void> _loadUserData() async {
    print('DEBUG: Empezando a cargar datos del usuario');
    try {
      final user = await _authService.getCurrentUser();
      print('DEBUG: Usuario cargado: ${user?.id}, email: ${user?.email}, nombre: ${user?.name}');
      
      if (user != null && mounted) {
        setState(() {
          // Usar el operador ?. para manejar posibles nulos
          _userName = user.name?.isNotEmpty == true ? user.name! : "Usuario";
          _userEmail = user.email.isNotEmpty ? user.email : "usuario@glucova.com";
          print('DEBUG: Estado actualizado - nombre: $_userName, email: $_userEmail');
        });
      } else {
        print('DEBUG: Usuario es nulo o widget desmontado');
      }
    } catch (e) {
      print('ERROR: Error al cargar datos del usuario: $e');
    }
  }
  
  @override  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: _getAppBarTitle(),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primaryBlue),
            onPressed: _loadUserData,
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.primaryBlue),
            onPressed: () {
              // Handle notifications
            },
          ),
        ],
      ),      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDashboard(),
          _buildProfileScreen(),
          const HistoryScreen(),
          const Center(child: Text("Dispositivos")),
          const Center(child: Text("Alertas")),
          const Center(child: Text("Contactos")),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // Método para cerrar sesión 
  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
  // Obtener el título de la barra de navegación según la pestaña seleccionada
  Widget _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return const Text("Dashboard", style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold));
      case 1:
        return const Text("Perfil", style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold));
      case 2:
        return const Text("Historial", style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold));
      case 3:
        return const Text("Dispositivos", style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold));
      case 4:
        return const Text("Alertas", style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold));
      case 5:
        return const Text("Contactos", style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold));
      default:
        return const Text("GlucoVa", style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold));
    }
  }

  // Pantalla de perfil con botón de cierre de sesión
  Widget _buildProfileScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.primaryBlue,
            child: Icon(Icons.person, color: Colors.white, size: 50),
          ),
          const SizedBox(height: 16),
          Text(
            _userName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          Text(
            _userEmail,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text("Cerrar sesión"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            onPressed: _logout,
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User greeting and last measurement
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primaryBlue,
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hola, ${_userName}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  Text(
                    "Última medición: ${_metrics.lastMeasurement}",
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Main metrics title
          const Text(
            "Métricas principales",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),

          // Metrics Grid - First Row
          Row(
            children: [
              // Glucose metric
              Expanded(
                child: _buildMetricCard(
                  title: "Glucosa",
                  value: "${_metrics.glucose} mg/dL",
                  trend: _metrics.glucoseTrend,
                  trendPositive: true,
                  icon: Icons.water_drop,
                  iconColor: Colors.red,
                ),
              ),
              const SizedBox(width: 16),
              // Blood pressure metric
              Expanded(
                child: _buildMetricCard(
                  title: "Presión",
                  value: _metrics.bloodPressure,
                  trend: _metrics.bloodPressureStatus,
                  trendPositive: null,
                  icon: Icons.favorite,
                  iconColor: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Metrics Grid - Second Row
          Row(
            children: [
              // Weight metric
              Expanded(
                child: _buildMetricCard(
                  title: "Peso",
                  value: "${_metrics.weight} kg",
                  trend: _metrics.weightTrend,
                  trendPositive: false,
                  icon: Icons.monitor_weight,
                  iconColor: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              // BMI metric
              Expanded(
                child: _buildMetricCard(
                  title: "IMC",
                  value: "${_metrics.bmi}",
                  trend: _metrics.bmiStatus,
                  trendPositive: null,
                  icon: Icons.calculate,
                  iconColor: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recent alerts
          const Text(
            "Alertas recientes",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),          // Alert list
          ..._alerts.map((alert) => _buildAlertCard(alert)).toList(),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String trend,
    required IconData icon,
    required Color iconColor,
    bool? trendPositive,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and icon
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Icon(icon, color: iconColor, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          
          // Value
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          
          // Trend
          Row(
            children: [
              if (trendPositive != null) 
                Icon(
                  trendPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  color: trendPositive ? Colors.green : Colors.red,
                  size: 14,
                ),
              const SizedBox(width: 4),
              Text(
                trend,
                style: TextStyle(
                  fontSize: 12,
                  color: trendPositive == null 
                      ? AppColors.textLight 
                      : trendPositive 
                          ? Colors.green 
                          : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(Alert alert) {
    final IconData iconData = alert.type == "glucose" 
        ? Icons.warning 
        : Icons.notifications;
    
    final Color iconColor = alert.type == "glucose" 
        ? Colors.red 
        : AppColors.primaryBlue;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withOpacity(0.1),
            ),
            child: Icon(iconData, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.message,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  "${alert.time}${alert.details.isNotEmpty ? ' - ${alert.details}' : ''}",
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),    );
  }  
    Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primaryBlue,
      unselectedItemColor: Colors.grey,
      // Aumentar el tamaño del ícono seleccionado
      selectedIconTheme: const IconThemeData(size: 28),
      unselectedIconTheme: const IconThemeData(size: 24),
      // Reducir espacio entre elementos para mostrar todos
      selectedFontSize: 12,
      unselectedFontSize: 10,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Perfil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history_outlined),
          activeIcon: Icon(Icons.history),
          label: 'Historial',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.devices_outlined),
          activeIcon: Icon(Icons.devices),
          label: 'Dispositivos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_outlined),
          activeIcon: Icon(Icons.notifications),
          label: 'Alertas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.contacts_outlined),
          activeIcon: Icon(Icons.contacts),
          label: 'Contactos',
        ),
      ],
    );
  }
}
