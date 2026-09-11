import 'package:flutter/material.dart';

enum AlertSeverity { info, warning, danger }

class AlertBanner extends StatefulWidget {
  final String title;
  final String message;
  final AlertSeverity severity;
  final VoidCallback? onDismiss;

  const AlertBanner({
    super.key,
    required this.title,
    required this.message,
    this.severity = AlertSeverity.warning,
    this.onDismiss,
  });

  @override
  State<AlertBanner> createState() => _AlertBannerState();
}

class _AlertBannerState extends State<AlertBanner> {
  bool _dismissed = false;

  Color _bgColor(bool isDark) {
    switch (widget.severity) {
      case AlertSeverity.info:
        return isDark ? const Color(0xFF1E3A5F) : const Color(0xFFE3F2FD);
      case AlertSeverity.warning:
        return isDark ? const Color(0xFF5A3A10) : const Color(0xFFFFF3E0);
      case AlertSeverity.danger:
        return isDark ? const Color(0xFF5A1E1E) : const Color(0xFFFFEBEE);
    }
  }

  Color _accentColor() {
    switch (widget.severity) {
      case AlertSeverity.info:
        return const Color(0xFF1976D2);
      case AlertSeverity.warning:
        return const Color(0xFFF57C00);
      case AlertSeverity.danger:
        return const Color(0xFFD32F2F);
    }
  }

  IconData _icon() {
    switch (widget.severity) {
      case AlertSeverity.info:
        return Icons.info_outline_rounded;
      case AlertSeverity.warning:
        return Icons.warning_amber_rounded;
      case AlertSeverity.danger:
        return Icons.report_problem_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = _accentColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _bgColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withOpacity(0.35), width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_icon(), color: accent, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.message,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isDark ? Colors.white70 : const Color(0xFF333E52),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Icon(Icons.close_rounded,
                size: 18, color: accent.withOpacity(0.7)),
            onPressed: () {
              setState(() => _dismissed = true);
              widget.onDismiss?.call();
            },
          ),
        ],
      ),
    );
  }
}
