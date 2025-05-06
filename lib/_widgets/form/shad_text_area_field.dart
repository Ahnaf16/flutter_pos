import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:pos/main.export.dart';

/// A Shad CN Design text area.
class ShadTextAreaField extends ShadFormDecoration<String> {
  /// Creates a Shad CN Design text area.
  ShadTextAreaField({
    super.key,
    super.decoration,
    super.onChanged,
    super.valueTransformer,
    super.enabled,
    super.onSaved,
    super.autovalidateMode = AutovalidateMode.disabled,
    super.onReset,
    super.focusNode,
    super.restorationId,
    String? name,
    String? initialValue,
    this.readOnly = false,
    this.autofocus = false,
    this.controller,
    this.onSubmitted,
    this.onTap,
    this.onTapOutside,
    this.label,
    this.hintText,
    this.isRequired = false,
    this.validators,
    this.padding,
    this.helperText,
    this.outsideTrailing,
    this.maxHeight = 500,
    this.minHeight = 100,
    this.resizable = true,
  }) : assert(initialValue == null || controller == null),
       super(
         name: name ?? label?.snakeCase ?? hintText?.snakeCase ?? 'field',
         initialValue: controller != null ? controller.text : initialValue,
         validator: FormBuilderValidators.compose([if (isRequired) FormBuilderValidators.required(), ...?validators]),

         builder: (FormFieldState<String?> field) {
           final state = field as _ShadTextAreaFieldState;
           return ShadInputDecorator(
             label: label == null ? null : Text(label).required(isRequired),
             description: helperText == null ? null : Text(helperText),
             error: state.hasError ? Text(state.errorText ?? '') : null,
             decoration: state.decoration,
             child: ShadTextarea(
               restorationId: restorationId,
               controller: state._effectiveController,
               focusNode: state.effectiveFocusNode,
               decoration: state.decoration,
               placeholder: hintText == null ? null : Text(hintText),
               padding: padding,
               autofocus: autofocus,
               readOnly: readOnly,
               onPressed: onTap,
               onPressedOutside: onTapOutside,
               onSubmitted: onSubmitted,
               enabled: state.enabled,
               maxHeight: maxHeight,
               minHeight: minHeight,
               resizable: resizable,
             ),
           );
         },
       );

  final bool autofocus;
  final TextEditingController? controller;
  final String? helperText;
  final String? hintText;
  final bool isRequired;
  final String? label;
  final ValueChanged<String>? onSubmitted;
  final GestureTapCallback? onTap;
  final TapRegionCallback? onTapOutside;
  final Widget? outsideTrailing;
  final EdgeInsets? padding;
  final bool readOnly;
  final double maxHeight;
  final double minHeight;
  final bool resizable;
  final List<FormFieldValidator<String>>? validators;

  @override
  ShadFormDecorationState<ShadTextAreaField, String> createState() => _ShadTextAreaFieldState();
}

class _ShadTextAreaFieldState extends ShadFormDecorationState<ShadTextAreaField, String> {
  TextEditingController? _controller;

  String get text => _effectiveController!.text;
  bool get hasValue => _effectiveController!.text.isNotEmpty;

  @override
  void didChange(String? value) {
    super.didChange(value);

    if (_effectiveController!.text != value) {
      _effectiveController!.text = value ?? '';
    }
  }

  @override
  void dispose() {
    // Dispose the _controller when initState created it
    _controller!.removeListener(_handleControllerChanged);
    if (null == widget.controller) {
      _controller!.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    //setting this to value instead of initialValue here is OK since we handle initial value in the parent class
    _controller = widget.controller ?? TextEditingController(text: value);
    _controller!.addListener(_handleControllerChanged);
  }

  @override
  void reset() {
    super.reset();
    setState(() {
      _effectiveController!.text = initialValue ?? '';
    });
  }

  TextEditingController? get _effectiveController => widget.controller ?? _controller;

  void _handleControllerChanged() {
    // Suppress changes that originated from within this class.
    //
    // In the case where a controller has been passed in to this widget, we
    // register this change listener. In these cases, we'll also receive change
    // notifications for changes originating from within this class -- for
    // example, the reset() method. In such cases, the FormField value will
    // already have been set.
    if (_effectiveController!.text != (value ?? '')) {
      didChange(_effectiveController!.text);
    }
  }
}
