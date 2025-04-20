import 'package:pos/main.export.dart';

enum LoadingPosition { leading, trailing, center }

class LoadingButton extends HookWidget {
  const LoadingButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.leading,
    this.trailing,
    this.loadingPosition = LoadingPosition.leading,
    this.margin,
    this.density,
    this.size,
  });

  final Function(ValueNotifier<bool> isLoading)? onPressed;
  final Widget child;
  final Widget? leading;
  final Widget? trailing;
  final EdgeInsetsGeometry? margin;
  final ButtonDensity? density;
  final ButtonSize? size;
  final LoadingPosition loadingPosition;

  @override
  Widget build(BuildContext context) {
    final isLoading = useState(false);

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: PrimaryButton(
        size: size ?? ButtonSize.normal,
        density: density ?? ButtonDensity.normal,
        onPressed: onPressed != null ? () => onPressed!(isLoading) : null,
        enabled: !isLoading.value,
        trailing: loadingPosition == LoadingPosition.trailing ? _buildLoading(trailing, isLoading.value) : null,
        leading: loadingPosition == LoadingPosition.leading ? _buildLoading(leading, isLoading.value) : null,
        child: loadingPosition == LoadingPosition.center ? (_buildLoading(child, isLoading.value)) ?? child : child,
      ),
    );
  }

  Widget? _buildLoading(Widget? child, bool loading) {
    return loading ? const Loading() : child;
  }
}
