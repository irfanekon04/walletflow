import 'package:flutter/material.dart';
import 'package:walletflow/core/utils/responsive.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24 * context.responsiveFontSize),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 64 * context.responsiveFontSize,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              SizedBox(height: 16 * context.responsiveFontSize),
            ],
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 20 * context.responsiveFontSize,
                  ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              SizedBox(height: 8 * context.responsiveFontSize),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      fontSize: 14 * context.responsiveFontSize,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              SizedBox(height: 24 * context.responsiveFontSize),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
