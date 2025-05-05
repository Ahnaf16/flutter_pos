import 'package:flutter/services.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:pos/main.export.dart';

/// A Shad CN Design text field input.
class ShadFormField extends ShadFormDecoration<String> {
  /// Creates a Shad CN Design text field input.
  ShadFormField({
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
    this.keyboardType,
    this.controller,
    this.textInputAction,
    this.onSubmitted,
    this.inputFormatters,
    this.expands = false,
    this.onTap,
    this.onTapOutside,
    this.label,
    this.hintText,
    this.isRequired = false,
    this.isPassField = false,
    this.validators,
    this.leading,
    this.padding,
    this.helperText,
    this.trailing,
    this.outsideTrailing,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.numeric = false,
    this.showClearButton = false,
    this.buttonVariant = ShadButtonVariant.ghost,
  }) : assert(initialValue == null || controller == null),
       super(
         name: name ?? label?.snakeCase ?? hintText?.snakeCase ?? 'field',
         initialValue: controller != null ? controller.text : initialValue,
         validator: FormBuilderValidators.compose([
           if (isRequired) FormBuilderValidators.required(),
           if (numeric) FormBuilderValidators.numeric(),
           ...?validators,
         ]),

         builder: (FormFieldState<String?> field) {
           final state = field as _ShadTextFieldState;
           return ShadInputDecorator(
             label: label == null ? null : Text(label).required(isRequired),
             description: helperText == null ? null : Text(helperText),
             error: state.hasError ? Text(state.errorText ?? '') : null,
             decoration: state.decoration,
             child: Row(
               children: [
                 Flexible(
                   child: ShadInput(
                     restorationId: restorationId,
                     controller: state._effectiveController,
                     focusNode: state.effectiveFocusNode,
                     decoration: state.decoration,
                     padding: padding,
                     keyboardType: keyboardType,
                     textInputAction: textInputAction,
                     autofocus: autofocus,
                     readOnly: readOnly,
                     maxLines: maxLines,
                     minLines: minLines,
                     expands: expands,
                     maxLength: maxLength,
                     onPressed: onTap,
                     onPressedOutside: onTapOutside,
                     onSubmitted: onSubmitted,
                     inputFormatters: [
                       ...?inputFormatters,
                       if (numeric) FilteringTextInputFormatter.allow(decimalRegExp),
                     ],
                     enabled: state.enabled,
                     obscureText: isPassField ? state.isObscure : false,
                     placeholder: hintText == null ? null : Text(hintText),

                     leading: leading,
                     trailing: Row(
                       mainAxisSize: MainAxisSize.min,
                       children: [
                         if (showClearButton && state.hasValue)
                           SmallButton(variant: buttonVariant, icon: LucideIcons.x, onPressed: () => state.clear()),
                         if (trailing != null) trailing,
                         if (isPassField)
                           SmallButton(
                             variant: buttonVariant,
                             icon: state.isObscure ? LucideIcons.eyeOff : LucideIcons.eye,
                             onPressed: () => state._toggleObscure(),
                           ),
                       ],
                     ),
                   ),
                 ),
                 if (outsideTrailing != null) outsideTrailing,
               ],
             ),
           );
         },
       );

  final bool autofocus;
  final bool numeric;
  final bool showClearButton;
  final TextEditingController? controller;
  final bool expands;
  final String? helperText;
  final String? hintText;
  final List<TextInputFormatter>? inputFormatters;
  final bool isPassField;
  final bool isRequired;
  final TextInputType? keyboardType;
  final String? label;
  final Icon? leading;
  final ValueChanged<String>? onSubmitted;
  final GestureTapCallback? onTap;
  final TapRegionCallback? onTapOutside;
  final Widget? outsideTrailing;
  final EdgeInsets? padding;
  final bool readOnly;
  final TextInputAction? textInputAction;
  final Widget? trailing;
  final List<FormFieldValidator<String>>? validators;
  final int? minLines;
  final int? maxLength;
  final int? maxLines;
  final ShadButtonVariant buttonVariant;

  @override
  ShadFormDecorationState<ShadFormField, String> createState() => _ShadTextFieldState();
}

class _ShadTextFieldState extends ShadFormDecorationState<ShadFormField, String> {
  TextEditingController? _controller;
  bool _obscure = true;
  bool get isObscure => _obscure;

  void _toggleObscure() {
    setState(() {
      _obscure = !_obscure;
    });
  }

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

  void clear() {
    setState(() {
      _effectiveController!.clear();
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
