import 'package:flutter/foundation.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pos/main.export.dart';

class ShadXFile {
  const ShadXFile(this.pathOrBytes, {required this.name});

  ShadXFile.path(String path, {required this.name}) : pathOrBytes = left(path);
  ShadXFile.bytes(Uint8List bytes, {required this.name}) : pathOrBytes = right(bytes);

  final Either<String, Uint8List> pathOrBytes;
  final String name;

  String? get extension => name.split('.').last;
}

// TODO
class ShadFileField<T> extends ShadFormDecoration<T> {
  ShadFileField({
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
    super.initialValue,
    this.label,
    this.hintText,
    this.isRequired = false,
    this.validators,
    this.helperText,
  }) : super(
         name: name ?? label?.snakeCase ?? hintText?.snakeCase ?? 'field',
         validator: FormBuilderValidators.compose([if (isRequired) FormBuilderValidators.required(), ...?validators]),
         builder: (FormFieldState<T?> field) {
           //  final state = field as _ShadFileFieldState<T>;
           return Builder(
             builder: (context) {
               return ShadCard(
                 title: Text('Upload File', style: context.text.p),
                 description: Text('Select a file to upload', style: context.text.muted),
                 padding: Pads.xl().copyWith(top: Insets.med),
                 childPadding: Pads.med('t'),
                 width: 700,
                 child: ShadDottedBorder(
                   child: Center(
                     child: Column(
                       children: [
                         const ShadAvatar(LuIcons.upload),
                         const Gap(Insets.med),
                         const Text('Drag and drop files here'),
                         Text('Or click browse (max 3MB)', style: context.text.muted.size(12)),
                         const Gap(Insets.med),
                         ShadButton.outline(
                           size: ShadButtonSize.sm,
                           child: const Text('Browse Files'),
                           onPressed: () {},
                         ),
                       ],
                     ),
                   ),
                 ),
               );
             },
           );
         },
       );

  final String? helperText;
  final String? hintText;
  final bool isRequired;
  final String? label;
  final List<FormFieldValidator<T>>? validators;

  @override
  ShadFormDecorationState<ShadFileField<T>, T> createState() => _ShadFileFieldState<T>();
}

class _ShadFileFieldState<T> extends ShadFormDecorationState<ShadFileField<T>, T> {
  // @override
  // void didChange(T? value) {
  //   super.didChange(value);
  //  }

  // @override
  // void dispose() {
  //   super.dispose();
  // }

  // @override
  // void initState() {
  //   super.initState();
  // }

  @override
  void reset() {
    super.reset();
    setState(() {});
  }

  void clear() {
    setState(() {});
  }
}

class ShadDottedBorder extends StatelessWidget {
  const ShadDottedBorder({
    super.key,
    required this.child,
    this.strokeWidth = 1,
    this.borderRadius,
    this.color,
    this.dashWidth = 5,
    this.dashSpace = 3,
    this.padding,
  });

  final Widget child;
  final double strokeWidth;
  final BorderRadius? borderRadius;
  final Color? color;
  final double dashWidth;
  final double dashSpace;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final borderColor = color ?? context.colors.border;
    final borderRadius = this.borderRadius ?? context.theme.radius;

    return CustomPaint(
      painter: _DottedBorderPainter(
        strokeWidth: strokeWidth,
        borderRadius: borderRadius,
        color: borderColor,
        dashWidth: dashWidth,
        dashSpace: dashSpace,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Padding(padding: padding ?? Pads.med(), child: child),
      ),
    );
  }
}

class _DottedBorderPainter extends CustomPainter {
  final double strokeWidth;
  final BorderRadius borderRadius;
  final Color color;
  final double dashWidth;
  final double dashSpace;

  _DottedBorderPainter({
    required this.strokeWidth,
    required this.borderRadius,
    required this.color,
    required this.dashWidth,
    required this.dashSpace,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = borderRadius.toRRect(Offset.zero & size);
    final path = Path()..addRRect(rrect);

    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        final extractPath = metric.extractPath(distance, next.clamp(0, metric.length));
        canvas.drawPath(extractPath, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
