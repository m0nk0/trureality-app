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
          color: result.statusColor.withValues(alpha: 0.2),
          border: Border.all(color: result.statusColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: result.statusColor.withValues(alpha: 0.3),
              blurRadius: 8,
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

  IconData _iconForStatus(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.verified: return Icons.check;
      case VerificationStatus.disputed: return Icons.close;
      case VerificationStatus.pending: return Icons.hourglass_empty;
      case VerificationStatus.unknown: return Icons.help_outline;
    }
  }
}