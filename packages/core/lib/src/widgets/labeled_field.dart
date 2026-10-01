import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/tokens/app_spacing.dart';

/// A text field with its label above it (design-system "Inputs"). The label,
/// helper and error are drawn here, not by `InputDecoration`, which only
/// floats a label inside the outline and indents helper text 12 px.
///
/// Works inside a `Form` ([validator]) and outside one ([errorText]). The
/// field is a real `TextField`, so `find.byType(TextField)` still matches.
class LabeledField extends StatefulWidget {
  const LabeledField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.helper,
    this.errorText,
    this.validator,
    this.keyboardType,
    this.autofillHints,
    this.textCapitalization = TextCapitalization.none,
    this.autofocus = false,
    this.minLines,
    this.maxLines = 1,
    this.password = false,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final String? helper;

  /// An error set by the caller. Wins over the [validator]'s message.
  final String? errorText;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final TextCapitalization textCapitalization;
  final bool autofocus;
  final int? minLines;
  final int? maxLines;

  /// Hides the text and adds a show/hide button.
  final bool password;
  final ValueChanged<String>? onSubmitted;

  @override
  State<LabeledField> createState() => _LabeledFieldState();
}

class _LabeledFieldState extends State<LabeledField> {
  TextEditingController? _own;
  var _hidden = true;

  TextEditingController get _controller =>
      widget.controller ?? (_own ??= TextEditingController());

  @override
  void dispose() {
    _own?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: (_) => widget.validator?.call(_controller.text),
      builder: (field) {
        final error = widget.errorText ?? field.errorText;
        return FieldFrame(
          label: widget.label,
          helper: widget.helper,
          error: error,
          child: Semantics(
            label: widget.label,
            child: TextField(
              controller: _controller,
              autofocus: widget.autofocus,
              keyboardType: widget.keyboardType,
              autofillHints: widget.autofillHints,
              textCapitalization: widget.textCapitalization,
              minLines: widget.minLines,
              maxLines: widget.password ? 1 : widget.maxLines,
              obscureText: widget.password && _hidden,
              onSubmitted: widget.onSubmitted,
              onChanged: field.didChange,
              decoration: InputDecoration(
                hintText: widget.hint,
                error: error == null ? null : const SizedBox.shrink(),
                suffixIcon: widget.password
                    ? IconButton(
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints.tightFor(
                          width: context.density.inputHeight,
                          height: context.density.inputHeight,
                        ),
                        tooltip: _hidden ? 'Parolayı göster' : 'Parolayı gizle',
                        icon: Icon(
                          _hidden
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _hidden = !_hidden),
                      )
                    : null,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A dropdown with its label above it, sized to the text fields' height. Not
/// `DropdownMenu`: its arrow is a fixed 48 px button the theme can't reach.
class LabeledDropdown<T> extends StatelessWidget {
  const LabeledDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.helper,
  });

  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T> onChanged;
  final String? helper;

  @override
  Widget build(BuildContext context) {
    return FieldFrame(
      label: label,
      helper: helper,
      child: Semantics(
        label: label,
        child: DropdownButtonFormField<T>(
          initialValue: value,
          // A long choice ("Orta hareketli") is cut with an ellipsis inside
          // the field instead of overflowing it at large text.
          isExpanded: true,
          iconSize: 20,
          // The content has a 24 px floor, taller than a text line, so the
          // padding is trimmed to land on the text fields' height.
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14,
              vertical: (context.density.inputHeight - 24) / 2,
            ),
          ),
          items: items,
          onChanged: (v) => onChanged(v as T),
        ),
      ),
    );
  }
}

/// The label above, the field, then the error (red, with an icon) or else the
/// helper, both on the field's own edge.
class FieldFrame extends StatelessWidget {
  const FieldFrame({
    super.key,
    required this.label,
    required this.child,
    this.helper,
    this.error,
  });

  final String label;
  final Widget child;
  final String? helper;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final error = this.error;
    final helper = this.helper;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(
          child: Text(
            label,
            style: text.titleSmall?.copyWith(color: palette.ink),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        child,
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Semantics(
              liveRegion: true,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Icon(
                      Icons.error_outline,
                      size: 14,
                      color: palette.error,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      error,
                      style: text.bodySmall?.copyWith(color: palette.error),
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (helper != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              helper,
              style: text.bodySmall?.copyWith(color: palette.textSecondary),
            ),
          ),
      ],
    );
  }
}
