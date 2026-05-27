import 'package:flutter/material.dart';

/// 🎨 5-цветная система вердиктов + технические статусы
enum VerificationStatus {
  verified,    // 🟢 Факт: подтверждено ≥2 источниками
  disproven,   // 🔴 Опровергнуто: фейк или манипуляция
  hypothesis,  // 🟡 Гипотеза: теория, слух, предварительные данные
  opinion,     // 🔵 Мнение: субъективная оценка, не факт
  unclear,     // ⚪ Неясно: недостаточно данных для вывода
  pending,     // ⏳ Загрузка / обработка
  unknown,     // ⚪ Ошибка / не проверено
}

class VerificationResult {
  final String statement;
  final VerificationStatus status;
  final String? explanation;
  final List<String> sources;
  final DateTime checkedAt;

  VerificationResult({
    required this.statement,
    required this.status,
    this.explanation,
    this.sources = const [],
    DateTime? checkedAt,
  }) : checkedAt = checkedAt ?? DateTime.now();

  /// 🎨 Цвет для индикатора (5 цветов + технические)
  Color get statusColor {
    switch (status) {
      case VerificationStatus.verified:
        return const Color(0xFF00D4AA); // 🟢 Бирюзовый
      case VerificationStatus.disproven:
        return const Color(0xFFFF4444); // 🔴 Красный
      case VerificationStatus.hypothesis:
        return const Color(0xFFFFBB33); // 🟡 Жёлтый
      case VerificationStatus.opinion:
        return const Color(0xFF4488FF); // 🔵 Синий
      case VerificationStatus.unclear:
        return const Color(0xFF888888); // ⚪ Серый
      case VerificationStatus.pending:
        return const Color(0xFFAAAAAA); // ⏳ Светло-серый (загрузка)
      case VerificationStatus.unknown:
        return Colors.grey;             // ⚪ Серый (ошибка)
    }
  }

  /// 🏷️ Текст статуса на русском
  String get statusLabel {
    switch (status) {
      case VerificationStatus.verified:
        return 'Подтверждено';
      case VerificationStatus.disproven:
        return 'Опровергнуто';
      case VerificationStatus.hypothesis:
        return 'Гипотеза';
      case VerificationStatus.opinion:
        return 'Мнение';
      case VerificationStatus.unclear:
        return 'Недостаточно данных';
      case VerificationStatus.pending:
        return 'Проверка...';
      case VerificationStatus.unknown:
        return 'Не проверено';
    }
  }

  /// 📝 Короткое описание для тултипа
  String get statusDescription {
    switch (status) {
      case VerificationStatus.verified:
        return 'Факт подтверждён независимыми источниками';
      case VerificationStatus.disproven:
        return 'Утверждение не соответствует действительности';
      case VerificationStatus.hypothesis:
        return 'Теория требует дополнительной проверки';
      case VerificationStatus.opinion:
        return 'Субъективная оценка, а не объективный факт';
      case VerificationStatus.unclear:
        return 'Недостаточно информации для вывода';
      case VerificationStatus.pending:
        return 'ИИ анализирует данные...';
      case VerificationStatus.unknown:
        return 'Проверка не была выполнена';
    }
  }

  /// 🎯 Иконка для статуса (опционально, для улучшения UX)
  IconData get statusIcon {
    switch (status) {
      case VerificationStatus.verified:
        return Icons.check_circle;
      case VerificationStatus.disproven:
        return Icons.cancel;
      case VerificationStatus.hypothesis:
        return Icons.psychology;
      case VerificationStatus.opinion:
        return Icons.chat_bubble_outline;
      case VerificationStatus.unclear:
      case VerificationStatus.unknown:
        return Icons.help_outline;
      case VerificationStatus.pending:
        return Icons.hourglass_empty;
    }
  }
}