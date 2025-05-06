import 'package:pos/main.export.dart';

enum LoadingPosition { leading, trailing, center }

class SubmitButton extends HookWidget {
  const SubmitButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.leading,
    this.trailing,
    this.loadingPosition = LoadingPosition.leading,
    this.margin,
    this.size,
    this.width,
    this.height,
    this.enabled = true,
    this.variant = ShadButtonVariant.primary,
  });

  final Function(ValueNotifier<bool> isLoading)? onPressed;
  final Widget child;
  final Widget? leading;
  final Widget? trailing;
  final EdgeInsetsGeometry? margin;
  final ShadButtonSize? size;
  final double? width;
  final double? height;
  final bool enabled;
  final ShadButtonVariant variant;

  final LoadingPosition loadingPosition;

  @override
  Widget build(BuildContext context) {
    final isLoading = useState(false);

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: ShadButton.raw(
        size: size,
        width: width,
        height: height,
        variant: variant,
        onPressed:
            (onPressed != null && !isLoading.value)
                ? () async {
                  try {
                    await onPressed!(isLoading);
                  } catch (e) {
                    rethrow;
                  } finally {
                    isLoading.value = false;
                  }
                }
                : null,
        enabled: enabled,
        trailing: loadingPosition == LoadingPosition.trailing ? _buildLoading(trailing, isLoading.value) : null,
        leading: loadingPosition == LoadingPosition.leading ? _buildLoading(leading, isLoading.value) : null,
        child: loadingPosition == LoadingPosition.center ? (_buildLoading(child, isLoading.value)) ?? child : child,
      ),
    );
  }

  Widget? _buildLoading(Widget? child, bool loading) {
    return loading ? const Loading(primary: false, size: 16) : child;
  }
}
