import 'package:pos/main.export.dart';

class ProtectedPage extends StatelessWidget {
  const ProtectedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseBody(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Flexible(child: body(context))],
        ),
      ),
    );
  }

  static ShadCard body(BuildContext context, [bool showBorder = true]) {
    return ShadCard(
      padding: Pads.xl(),
      border: showBorder ? null : const Border(),
      shadows: showBorder ? const [] : null,
      child: Center(
        child: Column(
          spacing: Insets.lg,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LuIcons.shield, size: 50),
            Text('Protected Page', style: context.text.h2),
            Text('You don\'t have permission to access this page', style: context.text.muted),
            ShadButton.outline(
              onPressed: () => RPaths.home.go(context),
              child: const SelectionContainer.disabled(child: Text('Go to home')),
            ),
          ],
        ),
      ),
    );
  }
}
