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
      if (showToast && isFailure) Toast.showErr(context, failure);
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
          Text(error.toString()),

          if (prov != null) const Gap(Insets.med),
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

class ErrorDisplay extends HookConsumerWidget {
  const ErrorDisplay(this.error, {super.key, this.description, this.prov});

  final String error;
  final String? description;
  final ProviderOrFamily? prov;

  Widget withSF() => Scaffold(appBar: AppBar(), body: this);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Widget? child;

    // child = Center(
    //   child: ShadCard(
    //     rowMainAxisSize: MainAxisSize.min,
    //     columnMainAxisSize: MainAxisSize.min,
    //     childPadding: Pads.xxxl(),
    //     child: Center(
    //       child: Column(
    //         spacing: Insets.lg,
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         children: [
    //           Text(error, style: context.text.h4),
    //           if (description != null) Text(description!, style: context.text.muted),
    //           const Gap(Insets.med),
    //           ShadButton.outline(
    //             onPressed: () {
    //               HapticFeedback.mediumImpact();
    //               if (prov != null) {
    //                 ref.invalidate(prov!);
    //               } else {
    //                 RPaths.home.go(context);
    //               }
    //             },

    //             child: Text(prov == null ? 'Go Back' : 'Retry'),
    //           ),
    //         ],
    //       ),
    //     ),
    //   ),
    // );

    return ShadDialog(
      title: Text(error),
      description: description == null ? null : Text(description!, style: context.text.muted),
      closeIconData: LuIcons.arrowLeft,
      actions: [
        if (prov != null)
          ShadButton.outline(
            onPressed: () {
              HapticFeedback.mediumImpact();
              ref.invalidate(prov!);
            },

            child: const Text('Retry'),
          ),
      ],
    );
  }
}
