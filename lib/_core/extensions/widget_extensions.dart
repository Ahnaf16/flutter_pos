import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:pos/main.export.dart';

extension TestWiEx on Text {
  Widget required([bool isRequired = true]) {
    return Builder(
      builder: (context) {
        return Text.rich(
          TextSpan(
            children: [
              TextSpan(text: data, style: style),
              if (isRequired)
                TextSpan(text: '*', style: (style ?? const TextStyle()).textColor(context.colors.destructive)),
            ],
          ),
        );
      },
    );
  }

  Widget get fit => FittedBox(child: this);

  Widget copyable([bool copyOnTap = false]) => clickable(
    onTap: copyOnTap ? () => Copier.copy(data) : null,
    onLongPress: !copyOnTap ? () => Copier.copy(data) : null,
  );
}

extension WidgetEx on Widget {
  Widget clickable({void Function()? onTap, void Function()? onLongPress}) {
    return GestureDetector(onTap: onTap, onLongPress: onLongPress, child: this);
  }

  Widget conditionalExpanded(bool condition, [int flex = 1]) => condition ? Expanded(flex: flex, child: this) : this;
  Widget conditionalFlexible(bool condition, [int flex = 1]) => condition ? Flexible(flex: flex, child: this) : this;

  Widget toolTip(String text) => ShadTooltip(builder: (context) => Text(text), child: this);
}

extension ShadIconButtonEx on ShadIconButton {
  ShadIconButton colored(Color? color, {bool filled = false}) {
    if (color == null) return this;
    return ShadIconButton.raw(
      key: key,
      variant: variant,
      backgroundColor: filled ? color : color.op2,
      foregroundColor: filled ? (color.computeLuminance() > 0.5 ? Colors.black : Colors.white) : color,
      hoverBackgroundColor: filled ? color.op9 : color.op3,
      hoverForegroundColor: filled ? (color.computeLuminance() > 0.5 ? Colors.black : Colors.white) : color,
      pressedBackgroundColor: pressedBackgroundColor,
      pressedForegroundColor: pressedForegroundColor,
      shadows: shadows,
      padding: padding,
      height: height,
      width: width,
      icon: icon,
      iconSize: iconSize,
      decoration: decoration,
      cursor: cursor,
      autofocus: autofocus,
      focusNode: focusNode,
      onPressed: onPressed,
      enabled: enabled,
      gradient: gradient,
      hoverStrategies: hoverStrategies,
      longPressDuration: longPressDuration,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      onLongPressEnd: onLongPressEnd,
      onDoubleTapCancel: onDoubleTapCancel,
      onLongPressCancel: onLongPressCancel,
      onDoubleTapDown: onDoubleTapDown,
      onLongPressDown: onLongPressDown,
      onLongPressStart: onLongPressStart,
      onSecondaryTapCancel: onSecondaryTapCancel,
      onSecondaryTapDown: onSecondaryTapDown,
      onSecondaryTapUp: onSecondaryTapUp,
      onFocusChange: onFocusChange,
      onHoverChange: onHoverChange,
      onLongPressUp: onLongPressUp,
      onTapCancel: onTapCancel,
      onTapDown: onTapDown,
      onTapUp: onTapUp,
      statesController: statesController,
    );
  }
}

extension ShadButtonEx on ShadButton {
  ShadButton compact() => ShadButton.ghost(padding: Pads.zero, height: 24, gap: 24, child: child);

  ShadButton colored(Color? color, {bool filled = false}) {
    if (color == null) return this;
    return ShadButton.raw(
      key: key,
      variant: variant,
      backgroundColor: filled ? color : color.op2,
      foregroundColor: filled ? (color.computeLuminance() > 0.5 ? Colors.black : Colors.white) : color,
      hoverBackgroundColor: filled ? color.op9 : color.op3,
      hoverForegroundColor: filled ? (color.computeLuminance() > 0.5 ? Colors.black : Colors.white) : color,
      pressedBackgroundColor: pressedBackgroundColor,
      pressedForegroundColor: pressedForegroundColor,
      shadows: shadows,
      textDecoration: textDecoration,
      textDirection: textDirection,
      padding: padding,
      height: height,
      width: width,
      decoration: decoration,
      size: size,
      gap: gap,
      expands: expands,
      cursor: cursor,
      crossAxisAlignment: crossAxisAlignment,
      autofocus: autofocus,
      focusNode: focusNode,
      gradient: gradient,
      hoverStrategies: hoverStrategies,
      hoverTextDecoration: hoverTextDecoration,
      longPressDuration: longPressDuration,
      mainAxisAlignment: mainAxisAlignment,
      onDoubleTap: onDoubleTap,
      onDoubleTapCancel: onDoubleTapCancel,
      onLongPress: onLongPress,
      onLongPressCancel: onLongPressCancel,
      onLongPressEnd: onLongPressEnd,
      onDoubleTapDown: onDoubleTapDown,
      onLongPressDown: onLongPressDown,
      onLongPressStart: onLongPressStart,
      onSecondaryTapCancel: onSecondaryTapCancel,
      onSecondaryTapDown: onSecondaryTapDown,
      onSecondaryTapUp: onSecondaryTapUp,
      onFocusChange: onFocusChange,
      onHoverChange: onHoverChange,
      onLongPressUp: onLongPressUp,
      onTapCancel: onTapCancel,
      onTapDown: onTapDown,
      onTapUp: onTapUp,
      statesController: statesController,
      enabled: enabled,
      leading: leading,
      trailing: trailing,
      onPressed: onPressed,
      child: child,
    );
  }
}

extension ShadBadgeEx on ShadBadge {
  ShadBadge colored(Color color) => ShadBadge(
    backgroundColor: color.op1,
    foregroundColor: color,
    hoverBackgroundColor: onPressed != null ? color.op2 : color.op1,
    cursor: cursor,
    key: key,
    onPressed: onPressed,
    padding: padding,
    shape: shape,
    child: child,
  );
}

extension ColorEX on Color {
  Color op(double opacity) => withValues(alpha: opacity);
  Color get op1 => op(.1);
  Color get op2 => op(.2);
  Color get op3 => op(.3);
  Color get op4 => op(.4);
  Color get op5 => op(.5);
  Color get op6 => op(.6);
  Color get op7 => op(.7);
  Color get op8 => op(.8);
  Color get op9 => op(.9);

  ColorFilter toFilter() => ColorFilter.mode(this, BlendMode.srcIn);
}

extension MaterialStateSet on Set<WidgetState> {
  bool get isHovered => contains(WidgetState.hovered);
  bool get isFocused => contains(WidgetState.focused);
  bool get isPressed => contains(WidgetState.pressed);
  bool get isDragged => contains(WidgetState.dragged);
  bool get isSelected => contains(WidgetState.selected);
  bool get isScrolledUnder => contains(WidgetState.scrolledUnder);
  bool get isDisabled => contains(WidgetState.disabled);
  bool get isError => contains(WidgetState.error);
}

extension FromEx on FormBuilderState {
  Map<String, dynamic> get transformedValues {
    return fields.map((key, value) => MapEntry(key, value.transformedValue));
  }
}
