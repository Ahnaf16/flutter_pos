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
}

extension ShadButtonEx on ShadButton {
  ShadButton compact() => ShadButton.ghost(padding: Pads.zero, height: 24, gap: 24, child: child);
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
