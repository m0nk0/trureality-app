import 'package:flutter/material.dart';

enum VerificationStatus { unknown, pending, verified, disputed }

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

  Color get statusColor {
    switch (status) {
      case VerificationStatus.verified: return const Color(0xFF00D4AA);
      case VerificationStatus.disputed: return Colors.redAccent;
      case VerificationStatus.pending: return Colors.amber;
      case VerificationStatus.unknown: return Colors.grey;
    }
  }

  String get statusLabel {
    switch (status) {
      case VerificationStatus.verified: return 'Подтверждено';
      case VerificationStatus.disputed: return 'Опровергнуто';
      case VerificationStatus.pending: return 'На проверке';
      case VerificationStatus.unknown: return 'Не проверено';
    }
  }
}