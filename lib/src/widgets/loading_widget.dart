// lib/widgets/loading_widget.dart

import 'package:flutter/material.dart';
import '../config/app_colors.dart';

/// Widget de carregamento customizado e reutilizável
/// 
/// Pode ser usado em qualquer lugar do app para indicar
/// operações em andamento de forma consistente
class LoadingWidget extends StatefulWidget {
  final double size;
  final Color? color;
  final String? message;
  final bool showMessage;
  
  const LoadingWidget({
    Key? key,
    this.size = 48.0,
    this.color,
    this.message,
    this.showMessage = true,
  }) : super(key: key);

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotation;
  late Animation<double> _pulse;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _rotation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));
    
    _pulse = Tween<double>(
      begin: 0.8,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.primary;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotation.value * 2 * 3.14159,
              child: Transform.scale(
                scale: _pulse.value,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Círculo externo
                    Container(
                      width: widget.size,
                      height: widget.size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: color.withOpacity(0.2),
                          width: 3,
                        ),
                      ),
                    ),
                    // Arco de progresso
                    SizedBox(
                      width: widget.size,
                      height: widget.size,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                    // Ícone central
                    Icon(
                      Icons.settings_input_antenna,
                      size: widget.size * 0.4,
                      color: color,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        if (widget.showMessage && widget.message != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.message!,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ],
    );
  }
}

/// Widget de loading para tela inteira
class FullScreenLoading extends StatelessWidget {
  final String? message;
  final bool isDismissible;
  
  const FullScreenLoading({
    Key? key,
    this.message = 'Carregando...',
    this.isDismissible = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => isDismissible,
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: LoadingWidget(
              message: message,
              showMessage: message != null,
            ),
          ),
        ),
      ),
    );
  }
  
  /// Mostra o loading em tela cheia
  static void show(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => FullScreenLoading(message: message),
    );
  }
  
  /// Esconde o loading em tela cheia
  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }
}

/// Widget de loading inline para listas e cards
class InlineLoading extends StatelessWidget {
  final String? message;
  final double size;
  
  const InlineLoading({
    Key? key,
    this.message,
    this.size = 24,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingWidget(
            size: size,
            showMessage: false,
          ),
          if (message != null) ...[
            const SizedBox(width: 16),
            Text(
              message!,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}