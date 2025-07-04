import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../config/firebase_config.dart';

/// Tela inicial que verifica o estado do sistema e do usuário
/// Esta é a primeira tela que o usuário vê ao abrir o aplicativo
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _statusMessage = 'Inicializando...';
  bool _hasError = false;
  
  @override
  void initState() {
    super.initState();
    // Inicia as verificações assim que a tela é criada
    _performSystemChecks();
  }
  
  /// Realiza todas as verificações necessárias do sistema
  Future<void> _performSystemChecks() async {
    try {
      // Passo 1: Verifica conexão com Firebase
      setState(() {
        _statusMessage = 'Verificando conexão com servidor...';
      });
      
      // Pequeno delay para o usuário ver a mensagem
      await Future.delayed(const Duration(seconds: 1));
      
      final isConnected = await FirebaseConfig.checkConnection();
      if (!isConnected) {
        setState(() {
          _statusMessage = 'Sem conexão com o servidor. Modo offline ativado.';
        });
        await Future.delayed(const Duration(seconds: 2));
      }
      
      // Passo 2: Verifica estado de autenticação
      setState(() {
        _statusMessage = 'Verificando autenticação...';
      });
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        setState(() {
          _statusMessage = 'Bem-vindo de volta, ${currentUser.email}!';
        });
        
        // TODO: Navegar para a home apropriada baseada no tipo de usuário
        // Por enquanto, vamos mostrar informações de debug
        await Future.delayed(const Duration(seconds: 2));
        _showDebugInfo(currentUser);
      } else {
        setState(() {
          _statusMessage = 'Redirecionando para login...';
        });
        
        // TODO: Navegar para tela de login
        await Future.delayed(const Duration(seconds: 2));
        _showDebugInfo(null);
      }
      
    } catch (e) {
      setState(() {
        _hasError = true;
        _statusMessage = 'Erro ao inicializar: ${e.toString()}';
      });
    }
  }
  
  /// Mostra informações de debug (temporário para verificação)
  void _showDebugInfo(User? user) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => _DebugScreen(user: user),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0066CC), // Azul Alfatronic
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo placeholder - substitua com o logo real da Alfatronic
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
                color: Color(0xFF0066CC),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Título do aplicativo
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
            
            // Indicador de carregamento
            if (!_hasError) ...[
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              const SizedBox(height: 20),
            ],
            
            // Mensagem de status
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _hasError ? Colors.red[300] : Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
            
            // Botão de retry em caso de erro
            if (_hasError) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _hasError = false;
                    _statusMessage = 'Tentando novamente...';
                  });
                  _performSystemChecks();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0066CC),
                ),
                child: const Text('Tentar Novamente'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Tela temporária de debug para verificar configurações
class _DebugScreen extends StatelessWidget {
  final User? user;
  
  const _DebugScreen({Key? key, this.user}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug - Verificação Firebase'),
        backgroundColor: const Color(0xFF0066CC),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Card de status da autenticação
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Status de Autenticação',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text('Usuário logado: ${user != null ? "Sim" : "Não"}'),
                  if (user != null) ...[
                    Text('Email: ${user.email ?? "N/A"}'),
                    Text('UID: ${user.uid}'),
                    Text('Email verificado: ${user.emailVerified ? "Sim" : "Não"}'),
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Card de configurações do Firebase
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Configurações Firebase',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text('Modo: ${FirebaseConfig.isDevelopment ? "Desenvolvimento" : "Produção"}'),
                  const Text('Firestore: Configurado ✓'),
                  const Text('Storage: Configurado ✓'),
                  const Text('Auth: Configurado ✓'),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Botões de teste
          if (user == null) ...[
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Navegar para tela de login
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tela de login ainda não implementada'),
                  ),
                );
              },
              icon: const Icon(Icons.login),
              label: const Text('Ir para Login'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ] else ...[
            ElevatedButton.icon(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const SplashScreen(),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Fazer Logout'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: Colors.red,
              ),
            ),
          ],
          
          const SizedBox(height: 16),
          
          // Informações adicionais
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Próximos Passos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text('1. Implementar tela de login'),
                  Text('2. Criar serviço de autenticação'),
                  Text('3. Configurar navegação por roles'),
                  Text('4. Implementar telas principais'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
