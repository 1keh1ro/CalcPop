import 'package:flutter/material.dart';
import 'package:calcpops/utils/app_colors.dart';

class CustomElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final TextStyle? textStyle;
  final double? elevation;
  final Color? shadowColor;
  final EdgeInsetsGeometry? padding;

  const CustomElevatedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.textStyle,
    this.elevation,
    this.shadowColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          foregroundColor: foregroundColor ?? AppColors.buttonTextDark,
          textStyle: textStyle ?? Theme.of(context).textTheme.displaySmall?.copyWith(
            color: AppColors.buttonTextDark,
            letterSpacing: 2,
          ),
          padding: padding ?? const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: elevation ?? 8,
          shadowColor: shadowColor ?? AppColors.accent.withOpacity(0.4),
        ),
        child: Text(text),
      ),
    );
  }
}
