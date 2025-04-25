import 'package:pos/main.export.dart';

class Toast {
  static void showErr(BuildContext context, dynamic message, {String? title, Widget? Function(String id)? action}) {
    String err = message.toString();

    if (message case final Failure f) err = f.message;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    action ??= (id) => _defAction(id, true, context);

    final sonner = ShadSonner.of(context);
    sonner.show(_buildToast(id, title, err, action, true));
  }

  static void show(BuildContext context, String message, {String? title, Widget? Function(String id)? action}) {
    final sonner = ShadSonner.of(context);
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    action ??= (id) => _defAction(id, true, context);

    sonner.show(_buildToast(id, title, message, action, false));
  }

  static Widget _defAction(String id, bool isDistractive, BuildContext ctx) {
    return ShadButton.ghost(
      onPressed: () => ShadSonner.of(ctx).hide(id),
      foregroundColor: isDistractive ? ctx.colors.destructiveForeground : ctx.colors.foreground,
      leading: const Icon(LuIcons.x),
      size: ShadButtonSize.sm,
      hoverBackgroundColor: isDistractive ? ctx.colors.destructiveForeground.op1 : null,
      hoverForegroundColor: isDistractive ? ctx.colors.destructiveForeground : ctx.colors.foreground,
    );
  }

  static ShadToast _buildToast(
    String id,
    String? title,
    String message,
    Widget? Function(String id) action,
    bool isDistractive,
  ) {
    return ShadToast.raw(
      id: id,
      title: title == null ? null : Text(title),
      description: Text(message),
      action: action.call(id),
      offset: const Offset(0, 20),
      alignment: Alignment.topRight,
      showCloseIconOnlyWhenHovered: true,
      padding: Pads.padding(h: Insets.lg, v: Insets.med),
      variant: isDistractive ? ShadToastVariant.destructive : ShadToastVariant.primary,
    );
  }
}
