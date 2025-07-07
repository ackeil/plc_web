// lib/screens/splash/splash_screen.dart

import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../services/auth_service.dart';

/// Tela inicial que verifica o estado de autenticação
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();
  
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }
  
  Future<void> _checkAuth() async {
    // Aguarda um pouco para mostrar a splash
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    // Verifica se há usuário logado
    final user = await _authService.getCurrentUser();
    
    if (user != null) {
      // Usuário logado, vai para home
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      // Não há usuário, vai para login
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.settings_remote,
                size: 80,
                color: AppColors.primary,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Título
            const Text(
              'AFT-PLC-WEB',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            
            const SizedBox(height: 10),
            
            // Subtítulo
            const Text(
              'Sistema de Monitoramento',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            
            const SizedBox(height: 60),
            
            // Loading
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}