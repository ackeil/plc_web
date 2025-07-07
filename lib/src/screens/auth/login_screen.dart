// lib/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';
import '../../config/app_colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

/// Tela de login do sistema AFT-PLC-WEB
/// 
/// Interface principal de autenticação que suporta tanto login real
/// quanto modo demonstração para apresentações offline
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  // Controladores dos campos de texto
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Chave do formulário para validações
  final _formKey = GlobalKey<FormState>();
  
  // Serviço de autenticação
  final _authService = AuthService();
  
  // Estados da tela
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  
  // Animação do logo
  late AnimationController _logoAnimationController;
  late Animation<double> _logoAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Configura animação do logo
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _logoAnimation = CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.elasticOut,
    );
    
    // Inicia a animação após um pequeno delay
    Future.delayed(const Duration(milliseconds: 200), () {
      _logoAnimationController.forward();
    });
    
    // Em modo debug, preenche campos para teste rápido
    if (const bool.fromEnvironment('dart.vm.product') == false) {
      _emailController.text = 'teste@ucs.br';
      _passwordController.text = 'Teste123';
    }
  }
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _logoAnimationController.dispose();
    super.dispose();
  }
  
  /// Realiza o processo de login
  Future<void> _handleLogin() async {
    // Valida o formulário
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Limpa mensagem de erro anterior
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });
    
    try {
      // Tenta fazer login
      final user = await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      // Se chegou aqui, login foi bem-sucedido
      if (mounted) {
        // Vibração de sucesso (mobile)
        HapticFeedback.lightImpact();
        
        // Mostra mensagem de boas-vindas
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bem-vindo, ${user.name}!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
        
        // Navega para a tela apropriada baseada no role
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (mounted) {
          // TODO: Implementar navegação baseada no role
          // Por enquanto, vamos para uma tela de debug
          Navigator.of(context).pushReplacementNamed('/home');
        }
      }
    } on AuthException catch (e) {
      // Erro esperado do nosso serviço
      setState(() {
        _errorMessage = e.message;
      });
      
      // Vibração de erro (mobile)
      HapticFeedback.heavyImpact();
    } catch (e) {
      // Erro inesperado
      setState(() {
        _errorMessage = 'Erro inesperado. Tente novamente.';
      });
      
      print('LoginScreen: Erro não tratado: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo animado
                    ScaleTransition(
                      scale: _logoAnimation,
                      child: Container(
                        width: isSmallScreen ? 120 : 150,
                        height: isSmallScreen ? 120 : 150,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: isSmallScreen ? 60 : 80,
                            height: isSmallScreen ? 60 : 80,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Título do app
                    Text(
                      'AFT-PLC-WEB',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 28 : 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: 2,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Subtítulo
                    Text(
                      'Sistema de Monitoramento',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    
                    const SizedBox(height: 48),
                    
                    // Mensagem de erro
                    if (_errorMessage != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    // Campo de email
                    CustomTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'seu.email@empresa.com',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      enabled: !_isLoading,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira seu email';
                        }
                        // Validação básica de email
                        if (!value.contains('@') || !value.contains('.')) {
                          return 'Email inválido';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Campo de senha
                    CustomTextField(
                      controller: _passwordController,
                      label: 'Senha',
                      hint: '••••••••',
                      prefixIcon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      enabled: !_isLoading,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira sua senha';
                        }
                        if (value.length < 6) {
                          return 'A senha deve ter pelo menos 6 caracteres';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => _handleLogin(),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Botão de login
                    CustomButton(
                      text: 'Entrar',
                      onPressed: _isLoading ? null : _handleLogin,
                      isLoading: _isLoading,
                      icon: Icons.login,
                      isFullWidth: true,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    const SizedBox(height: 16),
                    
                    // Footer
                    Text(
                      '© 2024 Alfatronic - Todos os direitos reservados',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}