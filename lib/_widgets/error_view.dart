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
    return ShadDialog(
      closeIconData: LuIcons.arrowLeft,
      closeIconPosition: const ShadPosition(left: 10, top: 10),
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
      child: Column(
        children: [
          Icon(LuIcons.circleOff, size: 40, color: context.colors.foreground.op5),
          const Gap(Insets.xl),
          Text(error, style: context.text.h3),
          const Gap(Insets.med),
          if (description != null) Text(description!, style: context.text.muted),
        ],
      ),
    );
  }
}

class EmptyWidget extends HookConsumerWidget {
  const EmptyWidget(
    this.title, {
    super.key,
    this.description,
    this.dense = false,
    this.bordered = true,
    this.height,
    this.width,
  });

  final String? title;
  final String? description;
  final bool dense;
  final bool bordered;
  final double? height;
  final double? width;

  Widget withSF() => Scaffold(appBar: AppBar(), body: this);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ShadCard(
      childPadding: Pads.med(),
      border: bordered ? null : const Border(),
      shadows: bordered ? null : [],
      height: height,
      width: width,
      child: Center(
        child: Flex(
          direction: dense ? Axis.horizontal : Axis.vertical,
          spacing: Insets.med,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LuIcons.triangleAlert200, color: context.colors.destructive.op6, size: dense ? 25 : 40),
            Text(title ?? 'No Item Found', style: dense ? context.text.list : context.text.lead),
            if (description != null) Text(description!, style: context.text.muted),
          ],
        ),
      ),
    );
  }
}
