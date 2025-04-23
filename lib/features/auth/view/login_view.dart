import 'package:google_fonts/google_fonts.dart';
import 'package:pos/main.export.dart';

class LoginView extends HookConsumerWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layout = context.layout;

    return Scaffold(
      body: Row(
        children: [
          if (layout.isDesktop)
            Expanded(
              child: DecoContainer(
                padding: context.layout.pagePadding,
                color: context.colors.border.op7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Flutter POS', style: context.textFromGoogle(GoogleFonts.rubik).h2),
                    Text('Every sale counts, every moment matters. Let\'s get started', style: context.text.h4),
                  ],
                ),
              ),
            ),

          Expanded(
            child: DecoContainer(
              padding: context.layout.pagePadding,
              child: LimitedWidthBox(
                maxWidth: 400,
                child: Column(
                  spacing: Insets.med,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Login', style: context.text.h3),
                    Text('Enter your email and password to login', style: context.text.muted),
                    const Gap(Insets.sm),
                    const ShadInput(placeholder: Text('Email')),

                    const ShadInput(placeholder: Text('Password')),

                    ShadButton(width: 400, onPressed: () {}, child: const Text('Login')),

                    const Gap(Insets.sm),
                    Text('By clicking login, you agree to our terms and conditions', style: context.text.muted),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
