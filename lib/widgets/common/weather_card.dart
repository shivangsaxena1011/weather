import 'package:flutter/material.dart';

/// A reusable, beautifully styled card wrapper for weather widgets.
class WeatherCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final Widget? titleTrailing;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final double borderRadius;
  final VoidCallback? onTap;

  const WeatherCard({
    super.key,
    required this.child,
    this.title,
    this.titleTrailing,
    this.padding,
    this.backgroundColor,
    this.borderRadius = 20,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = backgroundColor ??
        (isDark
            ? const Color(0xFF1E2430)
            : const Color(0xFFF8FAFF));

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title!,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? Colors.white70
                          : Colors.black54,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                if (titleTrailing != null) titleTrailing!,
              ],
            ),
          ),
        child,
      ],
    );

    final card = Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.black.withOpacity(0.04),
          width: 1,
        ),
      ),
      child: content,
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }
}
