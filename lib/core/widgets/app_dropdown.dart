import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:walletflow/core/utils/responsive.dart';

import 'package:flutter/services.dart';

class AppDropdown<T> extends StatefulWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? label;
  final String? hint;
  final String? errorText;
  final String? Function(T?)? validator;
  final Widget? prefixIcon;
  final bool isExpanded;

  const AppDropdown({
    super.key,
    this.value,
    required this.items,
    this.onChanged,
    this.label,
    this.hint,
    this.errorText,
    this.validator,
    this.prefixIcon,
    this.isExpanded = true,
  });

  @override
  State<AppDropdown<T>> createState() => _AppDropdownState<T>();
}

class _AppDropdownState<T> extends State<AppDropdown<T>> {
  final GlobalKey<FormFieldState<T>> _fieldKey = GlobalKey<FormFieldState<T>>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final responsiveScale = context.responsiveFontSize;
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Find current selected item child to display in the field
    Widget? selectedChild;
    try {
      selectedChild =
          widget.items
              .firstWhereOrNull((item) => item.value == widget.value)
              ?.child;
    } catch (_) {
      selectedChild = null;
    }

    return FormField<T>(
      key: _fieldKey,
      initialValue: widget.value,
      validator: widget.validator,
      builder: (FormFieldState<T> state) {
        final hasError = state.hasError;
        final errorText = state.errorText;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.label != null) ...[
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  widget.label!,
                  style: textTheme.labelLarge?.copyWith(
                    color:
                        hasError
                            ? colorScheme.error
                            : colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                _showSelectionSheet(context, state);
              },
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                  horizontal: 20 * responsiveScale,
                  vertical: 16 * responsiveScale,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        hasError
                            ? colorScheme.error
                            : colorScheme.outlineVariant.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    if (widget.prefixIcon != null) ...[
                      IconTheme(
                        data: IconThemeData(
                          color: colorScheme.primary,
                          size: 20 * responsiveScale,
                        ),
                        child: widget.prefixIcon!,
                      ),
                      const SizedBox(width: 16),
                    ],
                    Expanded(
                      child:
                          selectedChild ??
                          Text(
                            widget.hint ?? 'Select an option',
                            style: textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: colorScheme.onSurfaceVariant,
                      size: 24 * responsiveScale,
                    ),
                  ],
                ),
              ),
            ),
            if (hasError && errorText != null)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 4),
                child: Text(
                  errorText,
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
                ),
              ),
          ],
        );
      },
    );
  }

  void _showSelectionSheet(BuildContext context, FormFieldState<T> state) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            top: 12,
            bottom: MediaQuery.of(context).padding.bottom + 20,
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              if (widget.label != null)
                Text(
                  'Select ${widget.label}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: widget.items.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = widget.items[index];
                    final isSelected = item.value == state.value;

                    return InkWell(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        // Dismiss the sheet FIRST to avoid context/rebuild issues
                        Navigator.of(context).pop();
                        
                        // Update state AFTER dismissing
                        state.didChange(item.value);
                        if (widget.onChanged != null) {
                          widget.onChanged!(item.value);
                        }
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primaryContainer.withValues(
                                  alpha: 0.5,
                                )
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : Colors.transparent,
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(child: item.child),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
