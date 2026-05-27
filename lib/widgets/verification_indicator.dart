import 'package:flutter/material.dart';
import '../models/verification_result.dart';

class VerificationIndicator extends StatelessWidget {
  final VerificationResult result;
  final VoidCallback? onTap;
  final double size;

  const VerificationIndicator({
    super.key,
    required this.result,
    this.onTap,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // Полупрозрачный фон
          color: result.statusColor.withValues(alpha: 0.15),
          // Цветная обводка
          border: Border.all(color: result.statusColor, width: 2),
          // Неоновое свечение
          boxShadow: [
            BoxShadow(
              color: result.statusColor.withValues(alpha: 0.4),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(
          _iconForStatus(result.status),
          color: result.statusColor,
          size: size * 0.6,
        ),
      ),
    );
  }

  /// 🎯 Возвращает иконку для каждого из 7 статусов
  IconData _iconForStatus(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.verified:
        return Icons.check;              // 🟢 Галочка
      case VerificationStatus.disproven:
        return Icons.close;              // 🔴 Крестик
      case VerificationStatus.hypothesis:
        return Icons.psychology;         // 🟡 Мозг / Теория
      case VerificationStatus.opinion:
        return Icons.chat_bubble_outline; // 🔵 Пузырь речи
      case VerificationStatus.unclear:
      case VerificationStatus.unknown:
        return Icons.help_outline;       // ⚪ Вопрос
      case VerificationStatus.pending:
        return Icons.hourglass_empty;    // ⏳ Песочные часы
      default:
        return Icons.error_outline;      // ⚠️ Фолбэк
    }
  }
}