import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:pos/main.export.dart';

class VisibilityField<T> extends StatelessWidget {
  const VisibilityField({
    super.key,
    required this.name,
    required this.data,
    this.visible = false,
    this.child,
    this.valueTransformer,
  });

  final String name;
  final T? data;
  final bool visible;
  final Widget? child;
  final Function(T? value)? valueTransformer;

  @override
  Widget build(BuildContext context) {
    return FormBuilderField<T>(
      name: name,
      initialValue: data,
      valueTransformer: valueTransformer,
      builder: (context) {
        return Visibility(visible: visible, child: child ?? const SizedBox.shrink());
      },
    );
  }
}
