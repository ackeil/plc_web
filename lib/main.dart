// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Arquivo gerado pelo FlutterFire CLI
import 'config/firebase_config.dart'; // Nossa configuração central
import 'screens/splash/splash_screen.dart';

void main() async {
  // Garante que o Flutter esteja inicializado antes do Firebase
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Inicializa o Firebase com as configurações da plataforma atual
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase inicializado com sucesso!');
    
    // Inicializa as configurações customizadas do Firebase
    FirebaseConfig.initialize();
    
    // Verifica a conexão em modo desenvolvimento
    if (FirebaseConfig.isDevelopment) {
      final isConnected = await FirebaseConfig.checkConnection();
      print('Conexão com Firebase: ${isConnected ? "OK" : "FALHOU"}');
    }
  } catch (e) {
    print('Erro ao inicializar Firebase: $e');
    // Em produção, você pode querer mostrar uma tela de erro
  }
  
  // Inicia o aplicativo apenas após o Firebase estar pronto
  runApp(const AftPlcWebApp());
}

class AftPlcWebApp extends StatelessWidget {
  const AftPlcWebApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AFT-PLC-WEB',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Cores da Alfatronic baseadas no logo
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF0066CC), // Azul Alfatronic
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        
        // Define o tema dos campos de texto
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        
        // Define o tema dos botões
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      
      // A SplashScreen será responsável por verificar o estado de autenticação
      home: const SplashScreen(),
    );
  }
}