
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum StatusSiaga {
  aman,
  waspada,
  siaga,
}

class StatusBadge extends StatelessWidget {
  final StatusSiaga status;
  final bool showIcon;

  const StatusBadge({
    super.key,
    required this.status,
    this.showIcon = true,
  });

  Color get warna {
    switch (status) {
      case StatusSiaga.aman:
        return AppTheme.safeColor;
      case StatusSiaga.waspada:
        return AppTheme.warningColor;
      case StatusSiaga.siaga:
        return AppTheme.dangerColor;
    }
  }

  String get label {
    switch (status) {
      case StatusSiaga.aman:
        return 'Aman';
      case StatusSiaga.waspada:
        return 'Waspada';
      case StatusSiaga.siaga:
        return 'Siaga';
    }
  }

  IconData get icon {
    switch (status) {
      case StatusSiaga.aman:
        return Icons.check_circle;
      case StatusSiaga.waspada:
        return Icons.warning_amber_rounded;
      case StatusSiaga.siaga:
        return Icons.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: warna.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: warna.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              icon,
              size: 16,
              color: warna,
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: warna,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
