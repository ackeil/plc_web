import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double? width;
  final double height;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final bool isLoading;
  final bool isOutlined;
  final double borderRadius;
  
  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
    this.height = 48,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final buttonBackgroundColor = backgroundColor ?? AppColors.primary;
    final buttonTextColor = textColor ?? (isOutlined ? AppColors.primary : Colors.white);
    
    final buttonContent = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(buttonTextColor),
            ),
          ),
          const SizedBox(width: 12),
        ],
        if (icon != null && !isLoading) ...[
          Icon(
            icon,
            color: buttonTextColor,
            size: 20,
          ),
          const SizedBox(width: 8),
        ],
        Text(
          isLoading ? 'Carregando...' : text,
          style: TextStyle(
            color: buttonTextColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
    
    if (isOutlined) {
      return SizedBox(
        width: width,
        height: height,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: isLoading ? AppColors.border : buttonBackgroundColor,
              width: 2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24),
          ),
          child: buttonContent,
        ),
      );
    }
    
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonBackgroundColor,
          foregroundColor: buttonTextColor,
          elevation: isLoading ? 0 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: buttonContent,
      ),
    );
  }
}