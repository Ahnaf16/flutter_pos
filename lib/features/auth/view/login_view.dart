import 'package:pos/main.export.dart';

class LoginView extends HookConsumerWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: DecoContainer(
              padding: context.layout.pagePadding,
              color: context.colors.border.op7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Flutter POS', style: context.text.h2),
                  Text('Every sale counts, every moment matters. Let\'s get started', style: context.text.h4),
                ],
              ),
            ),
          ),
          const VerticalDivider(),
          Expanded(
            child: DecoContainer(
              padding: context.layout.pagePadding,
              child: Column(
                spacing: Insets.med,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Login', style: context.text.h3),

                  Text('Enter your email and password to login', style: context.text.muted),

                  const ShadInput(placeholder: Text('Email')),

                  const ShadInput(placeholder: Text('Password')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
