import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class SensorCard extends StatelessWidget {
  final String jenisSensor;
  final String lokasi;
  final double nilai;
  final String satuan;
  final IconData icon;
  final Color warna;
  final VoidCallback? onTap;

  const SensorCard({
    super.key,
    required this.jenisSensor,
    required this.lokasi,
    required this.nilai,
    required this.satuan,
    required this.icon,
    required this.warna,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: warna.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: warna,
                      size: 26,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.sensors,
                    color: AppTheme.safeColor,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                jenisSensor,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                lokasi,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    nilai.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: warna,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(
                      satuan,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.circle,
                    color: AppTheme.safeColor,
                    size: 9,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Sensor Aktif',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.safeColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
