import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'utils/app_colors.dart';
import 'services/auth_service.dart';
import 'package:flutter/foundation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Agregamos un pequeño delay para evitar un flash de la pantalla de carga
    // si el token está disponible inmediatamente
    await Future.delayed(const Duration(milliseconds: 200));
    
    try {
      final user = await _authService.getCurrentUser();
      if (mounted) {
        setState(() {
          _isLoggedIn = user != null;
          _isLoading = false;
        });
        if (kDebugMode) {
          print('Usuario autenticado: ${user?.email}');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _isLoading = false;
        });
        if (kDebugMode) {
          print('Error al verificar autenticación: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // No podemos usar initialRoute y home al mismo tiempo
    // Si estamos cargando, mostramos la pantalla de carga
    // De lo contrario, configuramos las rutas y navegamos según el estado de autenticación
    if (_isLoading) {
      return MaterialApp(
        title: 'GlucoVa',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primaryRed,
            primary: AppColors.primaryRed,
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: Scaffold(
          backgroundColor: AppColors.background,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/glucova_logo.png',
                  height: 80,
                ),
                const SizedBox(height: 20),
                const CircularProgressIndicator(
                  color: AppColors.primaryRed,
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    // Si ya terminamos de cargar, navegamos según el estado de autenticación
    return MaterialApp(
      title: 'GlucoVa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryRed,
          primary: AppColors.primaryRed,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: _isLoggedIn ? const DashboardScreen() : const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}
