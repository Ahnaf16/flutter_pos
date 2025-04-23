import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos/features/auth/controller/auth_ctrl.dart';
import 'package:pos/main.export.dart';

class LoginView extends HookConsumerWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layout = context.layout;

    final authCtrl = useCallback(() => ref.read(authCtrlProvider.notifier));

    final email = useTextEditingController();
    final password = useTextEditingController();
    final showPass = useState(false);

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
                    ShadInput(placeholder: const Text('Email'), controller: email),

                    ShadInput(
                      placeholder: const Text('Password'),
                      controller: password,
                      obscureText: !showPass.value,
                      trailing: GestureDetector(
                        child: Icon(showPass.value ? Icons.visibility : Icons.visibility_off),
                        onTap: () => showPass.toggle(),
                      ),
                    ),

                    SubmitButton(
                      width: 400,
                      onPressed: (l) async {
                        l.value = true;
                        await authCtrl().signIn(email.text, password.text);
                        l.value = false;
                      },
                      child: const Text('Login'),
                    ),

                    const Gap(Insets.sm),
                    Text('By clicking login, you agree to our terms and conditions', style: context.text.muted),
                    if (!kReleaseMode)
                      Row(
                        children: [
                          ShadButton.outline(
                            child: const Text('Admin'),
                            onPressed: () {
                              email.text = 'admin@gmail.com';
                              password.text = '12341234';
                            },
                          ),
                        ],
                      ),
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
