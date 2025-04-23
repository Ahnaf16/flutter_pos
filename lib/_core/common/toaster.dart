import 'package:pos/main.export.dart';

class Toast {
  static final _context = Ctx.context;

  static void showErr(dynamic message, {String? title, Widget? Function(String id)? action}) {
    String err = message.toString();

    if (message case final Failure f) err = f.message;

    final sonner = ShadSonner.of(_context);
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    action ??= (id) => _defAction(id, true);

    sonner.show(_buildToast(id, title, err, action, true));
  }

  static void show(String message, {String? title, Widget? Function(String id)? action}) {
    final sonner = ShadSonner.of(_context);
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    action ??= (id) => _defAction(id, true);

    sonner.show(_buildToast(id, title, message, action, false));
  }

  static Widget _defAction(String id, bool isDistractive) {
    return ShadButton.ghost(
      onPressed: () => ShadSonner.of(_context).hide(id),
      foregroundColor: isDistractive ? _context.colors.destructiveForeground : _context.colors.foreground,
      leading: const Icon(LuIcons.x),
      size: ShadButtonSize.sm,
      hoverBackgroundColor: isDistractive ? _context.colors.destructiveForeground.op1 : null,
      hoverForegroundColor: isDistractive ? _context.colors.destructiveForeground : _context.colors.foreground,
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
