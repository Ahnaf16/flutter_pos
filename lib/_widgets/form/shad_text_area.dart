import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:pos/main.export.dart';

class TextArea extends StatefulWidget {
  const TextArea({
    Key? key,
    Key? superKey,
    this.expandableHeight = false,
    this.expandableWidth = false,
    this.initialHeight = 100,
    this.initialWidth = double.infinity,
    this.onHeightChanged,
    this.onWidthChanged,
    this.controller,
    this.leading,
    this.trailing,
    this.onSubmit,
    this.focusNode,
    this.onTap,
    this.enabled = true,
    this.readOnly = false,
    this.initialValue,
    this.maxLength,
    this.textAlign = TextAlign.start,
    this.minWidth = 100,
    this.minHeight = 100,
    this.maxWidth = double.infinity,
    this.maxHeight = double.infinity,
    this.onChanged,
    this.inputFormatters,
    this.keyboardType,
    this.textInputAction,
    this.decoration,
    this.helperText,
    this.label,
    this.hintText,
    this.name,
    this.isRequired = false,
    this.validators,
  }) : _key = key,
       super(key: superKey);

  final bool expandableHeight;
  final bool expandableWidth;
  final double initialHeight;
  final double initialWidth;

  final double minHeight;
  final double maxHeight;
  final double minWidth;
  final double maxWidth;

  final TextEditingController? controller;
  final ShadDecoration? decoration;
  final bool enabled;
  final FocusNode? focusNode;
  final String? helperText;
  final String? hintText;
  final String? initialValue;
  final List<TextInputFormatter>? inputFormatters;
  final bool isRequired;
  final TextInputType? keyboardType;
  final String? label;
  final Icon? leading;
  final int? maxLength;
  final String? name;
  final ValueChanged<String>? onChanged;
  final ValueChanged<double>? onHeightChanged;
  final ValueChanged<String>? onSubmit;
  final VoidCallback? onTap;
  final ValueChanged<double>? onWidthChanged;
  final bool readOnly;
  final TextAlign textAlign;
  final TextInputAction? textInputAction;
  final Widget? trailing;
  final List<FormFieldValidator<String>>? validators;
  final Key? _key;

  @override
  State<TextArea> createState() => _TextAreaState();
}

class _TextAreaState extends State<TextArea> {
  late double _height;
  late double _width;

  @override
  void didUpdateWidget(covariant TextArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialHeight != oldWidget.initialHeight) {
      _height = widget.initialHeight;
    }
    if (widget.initialWidth != oldWidget.initialWidth) {
      _width = widget.initialWidth;
    }
  }

  @override
  void initState() {
    super.initState();
    _height = widget.initialHeight;
    _width = widget.initialWidth;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = context.colors;

    final decoration = widget.decoration ?? theme.decoration;

    final defaultErrorStyle = theme.textTheme.muted.copyWith(fontWeight: FontWeight.w500, color: colors.destructive);
    final defaultLabelStyle = theme.textTheme.muted.copyWith(fontWeight: FontWeight.w500, color: colors.foreground);

    final errorStyle = decoration.errorStyle ?? defaultErrorStyle;

    final fallbackToLabelStyle = decoration.fallbackToLabelStyle ?? true;

    return FormBuilderField<String>(
      key: widget._key,
      name: widget.name ?? widget.label?.snakeCase ?? widget.hintText?.snakeCase ?? 'field',
      initialValue: widget.initialValue,
      validator: FormBuilderValidators.compose([
        if (widget.isRequired) FormBuilderValidators.required(),
        ...?widget.validators,
      ]),
      onChanged: (v) => v == null ? null : widget.onChanged?.call(v),
      enabled: widget.enabled,
      focusNode: widget.focusNode,
      builder: (state) {
        TextStyle? labelStyle = switch (state.hasError) {
          true => decoration.errorLabelStyle,
          false => decoration.labelStyle,
        };

        if (fallbackToLabelStyle && labelStyle == null) {
          labelStyle = decoration.labelStyle ?? (state.hasError ? defaultErrorStyle : defaultLabelStyle);
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.label != null)
              Padding(
                padding: decoration.labelPadding ?? Pads.sm('b'),
                child: Text(widget.label!, style: labelStyle).required(widget.isRequired),
              ),

            SizedBox(
              height: _height,
              width: _width,
              child: Stack(
                fit: StackFit.passthrough,
                children: [
                  Positioned.fill(
                    child: ShadInput(
                      controller: widget.controller,
                      onSubmitted: widget.onSubmit,
                      focusNode: widget.focusNode,
                      onPressed: widget.onTap,
                      enabled: widget.enabled,
                      readOnly: widget.readOnly,
                      initialValue: state.value,
                      maxLength: widget.maxLength,
                      maxLines: null,
                      expands: true,
                      textAlign: widget.textAlign,
                      onChanged: (v) => state.didChange(v),
                      inputFormatters: widget.inputFormatters,
                      keyboardType: widget.keyboardType,
                      textInputAction: widget.textInputAction,
                      decoration: decoration.copyWith(hasError: true),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      placeholder: widget.hintText == null ? null : Text(widget.hintText!),

                      leading: widget.leading,
                      trailing: widget.trailing,
                    ),
                  ),
                  Positioned(
                    bottom: -1,
                    right: -1,
                    width: (8 + 8),
                    height: (8 + 8),
                    child: MouseRegion(
                      hitTestBehavior: HitTestBehavior.translucent,
                      cursor:
                          widget.expandableWidth
                              ? widget.expandableHeight
                                  ? SystemMouseCursors.resizeDownRight
                                  : SystemMouseCursors.resizeLeftRight
                              : widget.expandableHeight
                              ? SystemMouseCursors.resizeUpDown
                              : SystemMouseCursors.basic,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onPanUpdate: (details) {
                          if (widget.expandableHeight && _height.isFinite) {
                            setState(() {
                              _height += details.delta.dy;
                              _height = _height.clamp(widget.minHeight, widget.maxHeight);
                              widget.onHeightChanged?.call(_height);
                            });
                          }
                          if (widget.expandableWidth && _width.isFinite) {
                            setState(() {
                              _width += details.delta.dx;
                              _width = _width.clamp(widget.minWidth, widget.maxWidth);
                              widget.onWidthChanged?.call(_width);
                            });
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: CustomPaint(painter: _TextAreaDragHandlePainter(context.colors.foreground)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (widget.helperText != null)
              Padding(
                padding: decoration.descriptionPadding ?? Pads.sm('t'),
                child: Text(widget.helperText!, style: decoration.descriptionStyle ?? theme.textTheme.muted),
              ),
            if (state.errorText != null)
              Padding(
                padding: decoration.errorPadding ?? Pads.sm('t'),
                child: Text(state.errorText!, style: errorStyle),
              ),
          ],
        );
      },
    );
  }
}

class _TextAreaDragHandlePainter extends CustomPainter {
  _TextAreaDragHandlePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 1
          ..strokeCap = StrokeCap.round;
    final start = Offset(size.width, 0);
    final end = Offset(0, size.height);
    final start2 = Offset(size.width, size.height / 2);
    final end2 = Offset(size.width / 2, size.height);
    canvas.drawLine(start, end, paint);
    canvas.drawLine(start2, end2, paint);
  }

  @override
  bool shouldRepaint(covariant _TextAreaDragHandlePainter oldDelegate) {
    return color != oldDelegate.color;
  }
}
