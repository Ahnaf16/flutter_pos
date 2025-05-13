import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:pos/main.export.dart';

/// A Shad CN Design text field input.
class ShadSelectField<T> extends ShadFormDecoration<T> {
  /// Creates a Shad CN Design text field input.
  ShadSelectField({
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
    T? initialValue,
    required this.optionBuilder,
    required this.options,
    this.selectedBuilder,
    this.controller,
    this.label,
    this.hintText,
    this.isRequired = false,
    this.validators,
    this.helperText,
    this.outsideTrailing,
    this.allowDeselection = true,
    this.maxHeight,
    this.maxWidth,
    this.minWidth,
    this.searchBuilder,
    this.anchor,
  }) : assert(initialValue == null || controller == null, 'Cannot provide both initialValue and controller'),
       super(
         name: name ?? label?.snakeCase ?? hintText?.snakeCase ?? 'field',
         initialValue: controller != null ? controller.value.firstOrNull : initialValue,
         validator: FormBuilderValidators.compose([if (isRequired) FormBuilderValidators.required(), ...?validators]),

         builder: (FormFieldState<T?> field) {
           final state = field as _ShadSelectFieldState<T>;
           final searchable = searchBuilder != null;
           return ShadInputDecorator(
             label: label == null ? null : Text(label).required(isRequired),
             description: helperText == null ? null : Text(helperText),
             error: state.hasError ? Text(state.errorText ?? '') : null,
             decoration: state.decoration,
             child: Row(
               children: [
                 Expanded(
                   child: Builder(
                     builder: (context) {
                       return ShadSelect<T>.raw(
                         variant: searchable ? ShadSelectVariant.search : ShadSelectVariant.primary,
                         enabled: enabled,
                         placeholder: Text(hintText ?? ''),
                         controller: state._effectiveController,
                         anchor: anchor,
                         selectedOptionBuilder: selectedBuilder ?? _defSelectedBuilder<T>,
                         options: [
                           if (options.isEmpty)
                             Padding(padding: Pads.padding(v: 24), child: const Text('No Item Found')),
                           for (int i = 0; i < options.length; i++)
                             Offstage(
                               offstage: !state.filtered.contains(options[i]),
                               child: ExcludeFocus(
                                 excluding: !state.filtered.contains(options[i]),
                                 child: optionBuilder(context, options[i], i),
                               ),
                             ),
                         ],
                         onChanged: (value) {
                           state.didChange(value);
                         },
                         decoration: state.decoration,
                         allowDeselection: allowDeselection,
                         itemCount: state.filtered.length,
                         maxHeight: maxHeight,
                         maxWidth: maxWidth,
                         minWidth: minWidth,
                         onSearchChanged: state.onSearchChanged,
                       );
                     },
                   ),
                 ),

                 if (outsideTrailing != null) outsideTrailing,
               ],
             ),
           );
         },
       );

  final ShadSelectedOptionBuilder<T>? selectedBuilder;
  final ShadSelectController<T>? controller;
  final ShadOption<T> Function(BuildContext context, T value, int index) optionBuilder;
  final List<T> options;
  final String? helperText;
  final String? hintText;
  final bool isRequired;
  final String? label;
  final Widget? outsideTrailing;
  final List<FormFieldValidator<T>>? validators;

  final bool allowDeselection;
  final double? maxHeight;
  final double? maxWidth;
  final double? minWidth;
  final String Function(T item)? searchBuilder;
  final ShadAnchorBase? anchor;

  static Widget _defSelectedBuilder<T>(BuildContext context, T value) => Text(value.toString());

  @override
  ShadFormDecorationState<ShadSelectField<T>, T> createState() => _ShadSelectFieldState<T>();
}

class _ShadSelectFieldState<T> extends ShadFormDecorationState<ShadSelectField<T>, T> {
  ShadSelectController<T>? _controller;

  String _searchValue = '';

  void onSearchChanged(String value) => setState(() => _searchValue = value);

  List<T> get filtered => [
    if (widget.searchBuilder == null)
      ...widget.options
    else
      for (final item in widget.options)
        if (widget.searchBuilder!(item).low.contains(_searchValue.low)) item,
  ];

  @override
  void didChange(T? value) {
    super.didChange(value);
    _effectiveController!.value = [if (value != null) value];
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller!.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ShadSelectController<T>(initialValue: [if (value != null) value!]);
  }

  @override
  void reset() {
    super.reset();
    setState(() {
      _effectiveController!.set([if (initialValue != null) initialValue!]);
    });
  }

  void clear() {
    setState(() {
      _effectiveController!.set([]);
    });
  }

  ShadSelectController<T>? get _effectiveController => widget.controller ?? _controller;
}
