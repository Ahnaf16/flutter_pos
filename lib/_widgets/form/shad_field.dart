import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:pos/main.export.dart';

@Deprecated('Use ShadFormField')
class ShadField extends HookWidget {
  const ShadField({
    Key? key,
    Key? superKey,
    this.name,
    this.label,
    this.hintText,
    this.isRequired = false,
    this.isPassField = false,
    this.initialValue,
    this.validators,
    this.keyboardType,
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
    this.onChanged,
    this.onSubmit,
    this.onTap,
    this.readOnly = false,
    this.enabled = true,
    this.leading,
    this.textInputAction,
    this.textAlign = TextAlign.start,
    this.inputFormatters,
    this.decoration,
    this.helperText,
    this.trailing,
    this.focusNode,
    this.expands = false,
    this.padding,
    this.outsideTrailing,
  }) : _key = key,
       super(key: superKey);

  final Key? _key;
  final String? name;
  final String? label;
  final String? hintText;
  final bool isRequired;
  final bool isPassField;
  final String? initialValue;
  final TextInputType? keyboardType;
  final List<FormFieldValidator<String>>? validators;
  final void Function(String value)? onChanged;
  final void Function(String value)? onSubmit;
  // final TextEditingController? controller;
  final bool readOnly;
  final bool enabled;
  final Function()? onTap;
  final Icon? leading;
  final TextInputAction? textInputAction;
  final TextAlign textAlign;
  final List<TextInputFormatter>? inputFormatters;
  final ShadDecoration? decoration;
  final String? helperText;
  final Widget? trailing;
  final Widget? outsideTrailing;
  final FocusNode? focusNode;
  final bool expands;
  final int? minLines;
  final int? maxLength;
  final int? maxLines;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final obscure = useState<bool>(true);
    final decoration = context.theme.decoration.mergeWith(this.decoration);

    return FormBuilderField<String>(
      key: _key,
      name: name ?? label?.snakeCase ?? hintText?.snakeCase ?? 'field',
      initialValue: initialValue,
      validator: FormBuilderValidators.compose([if (isRequired) FormBuilderValidators.required(), ...?validators]),
      onReset: () {},
      enabled: enabled,
      focusNode: focusNode,
      builder: (state) {
        return ShadInputDecorator(
          label: label == null ? null : Text(label!).required(isRequired),
          description: helperText == null ? null : Text(helperText!),
          error: state.hasError ? Text(state.errorText ?? '') : null,
          decoration: decoration.copyWith(hasError: state.hasError),
          child: Row(
            children: [
              Flexible(
                child: ShadInput(
                  initialValue: state.value,
                  placeholder: hintText == null ? null : Text(hintText!),
                  decoration: decoration.copyWith(hasError: state.hasError),
                  onChanged: (v) {
                    state.didChange(v);
                    onChanged?.call(v);
                  },
                  onSubmitted: (v) => onSubmit?.call(v),
                  readOnly: readOnly,
                  maxLength: maxLength,
                  maxLines: maxLines,
                  minLines: minLines,
                  keyboardType: keyboardType,
                  textInputAction: textInputAction,
                  textAlign: textAlign,
                  inputFormatters: inputFormatters,
                  onPressed: onTap,
                  enabled: enabled,
                  obscureText: isPassField ? obscure.value : false,
                  expands: expands,
                  leading: leading,
                  padding: padding,
                  trailing:
                      isPassField
                          ? ShadButton.ghost(
                            width: 24,
                            height: 24,
                            padding: Pads.zero,
                            decoration: const ShadDecoration(
                              secondaryBorder: ShadBorder.none,
                              secondaryFocusedBorder: ShadBorder.none,
                            ),
                            leading: Icon(obscure.value ? LucideIcons.eyeOff : LucideIcons.eye),
                            onPressed: () => obscure.toggle(),
                          )
                          : trailing,
                ),
              ),
              if (outsideTrailing != null) outsideTrailing!,
            ],
          ),
        );
      },
    );
  }
}
