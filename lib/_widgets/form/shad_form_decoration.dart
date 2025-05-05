import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:pos/main.export.dart';

class ShadFormDecoration<T> extends FormBuilderField<T> {
  const ShadFormDecoration({
    super.key,
    super.onSaved,
    super.initialValue,
    super.autovalidateMode,
    super.enabled = true,
    super.validator,
    super.restorationId,
    required super.name,
    super.valueTransformer,
    super.onChanged,
    super.onReset,
    super.focusNode,
    required super.builder,
    this.decoration = const ShadDecoration(),
  });
  final ShadDecoration decoration;

  @override
  ShadFormDecorationState<ShadFormDecoration<T>, T> createState() =>
      ShadFormDecorationState<ShadFormDecoration<T>, T>();
}

class ShadFormDecorationState<F extends ShadFormDecoration<T>, T>
    extends FormBuilderFieldState<FormBuilderField<T>, T> {
  @override
  F get widget => super.widget as F;

  /// Get the decoration with the current state
  ShadDecoration get decoration => widget.decoration.copyWith(
    // Read only allow show error to support property skipDisabled
    hasError: widget.enabled || readOnly ? super.hasError : false,
  );

  @override
  bool get isValid => super.isValid && super.hasError == false;
}
