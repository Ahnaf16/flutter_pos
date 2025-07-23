import 'package:pos/main.export.dart';

typedef StyleBuilder = (TextStyle, TextStyle) Function(TextStyle left, TextStyle right);

class SpacedText extends StatelessWidget {
  const SpacedText({
    super.key,
    required this.left,
    required this.right,
    this.leading,
    this.trailing,
    this.separator = ' : ',
    this.style,
    this.onTap,
    this.styleBuilder,
    this.spaced = true,
    this.crossAxisAlignment,
    this.builder,
    this.enableSelection = true,
    this.mainAxisAlignment,
    this.useFlexible = true,
    this.maxLines,
  });

  static (TextStyle?, TextStyle?) buildStye(left, right) => (left, right);

  final Widget? leading;
  final String left;

  /// Default style for both texts
  final TextStyle? style;
  final String right;
  final String separator;
  final Widget? trailing;
  final void Function(String left, String right)? onTap;

  /// Override style for left and right
  final StyleBuilder? styleBuilder;

  final bool spaced;
  final CrossAxisAlignment? crossAxisAlignment;
  final MainAxisAlignment? mainAxisAlignment;

  final Widget Function(String right)? builder;
  final bool enableSelection;
  final bool useFlexible;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = style ?? context.text.small;
    final defBuilder = (effectiveStyle, effectiveStyle);

    final (lSty, rSty) = styleBuilder?.call(effectiveStyle, effectiveStyle) ?? defBuilder;

    return GestureDetector(
      onTap: onTap == null ? null : () => onTap?.call(left, right),
      child: Row(
        mainAxisAlignment: spaced ? MainAxisAlignment.spaceBetween : (mainAxisAlignment ?? MainAxisAlignment.start),
        crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.start,
        children: [
          Text('$left$separator', style: lSty),
          const Gap(Insets.med),
          ...[
            if (leading != null) ...[leading!, const Gap(Insets.sm)],
            DefaultTextStyle(
              style: rSty,
              textAlign: spaced ? TextAlign.end : TextAlign.start,
              child: builder?.call(right) ?? Text(right, maxLines: maxLines, overflow: TextOverflow.ellipsis),
            ).conditionalFlexible(useFlexible),
            if (trailing != null) ...[const Gap(Insets.sm), trailing!],
          ],
        ],
      ),
    );
  }
}
