import 'package:flutter/material.dart';

class VitalCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final VoidCallback onTap;
  final bool isHighContrast;

  const VitalCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.onTap,
    this.isHighContrast = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isHighContrast ? Colors.black : Colors.white;
    final borderColor = isHighContrast ? Colors.white : Colors.transparent;
    final titleColor = isHighContrast ? Colors.white70 : Colors.grey[500];
    final valueColor = isHighContrast ? Colors.yellowAccent : const Color(0xFF1F2937);
    final unitColor = isHighContrast ? Colors.white70 : Colors.grey[500];

    final iconBoxColor = isHighContrast ? Colors.grey[900] : iconBgColor;
    final iconBoxIconColor = isHighContrast ? Colors.yellowAccent : iconColor;
    final iconBoxBorder = isHighContrast ? Border.all(color: Colors.white) : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: isHighContrast ? 2 : 0),
          boxShadow: isHighContrast ? null : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBoxColor,
                borderRadius: BorderRadius.circular(12),
                border: iconBoxBorder,
              ),
              child: Icon(icon, color: iconBoxIconColor, size: 20),
            ),
            const Spacer(),
            Text(
              title,
              style: TextStyle(
                  color: titleColor,
                  fontSize: 12,
                  overflow: TextOverflow.ellipsis
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: valueColor,
                    overflow: TextOverflow.ellipsis
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    unit,
                    style: TextStyle(
                        fontSize: 12,
                        color: unitColor,
                        overflow: TextOverflow.ellipsis
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}