import 'package:flutter/services.dart';
import 'package:pos/main.export.dart';

class ErrorView extends HookConsumerWidget {
  const ErrorView(
    this.error,
    this.stackTrace, {
    super.key,
    this.showToast = true,
    this.prov,
    this.builder,
    this.scrollable = false,
  });

  final dynamic error;
  final StackTrace? stackTrace;
  final bool showToast;
  final ProviderOrFamily? prov;
  final Widget Function()? builder;
  final bool scrollable;

  Widget withSF() => Scaffold(appBar: AppBar(), body: this);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFailure = error is Failure;

    useEffect(() {
      if (showToast && isFailure) Toast.showErr(failure);
      return null;
    }, const []);

    Widget? child = builder?.call();
    if (child != null) return child;

    child = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(kError('ErrorView'), style: context.text.large),
          const Gap(Insets.sm),
          Flexible(child: Text(error.toString())),

          if (prov != null)
            ShadButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                ref.invalidate(prov!);
              },
              onLongPress: () {
                HapticFeedback.mediumImpact();
                catErr('ErrorView', error, stackTrace);
              },
              child: const Text('Retry'),
            ),
        ],
      ),
    );

    return scrollable ? SingleChildScrollView(child: child) : child;
  }
}
