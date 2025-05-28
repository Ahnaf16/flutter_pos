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
    final obscure = useState(true);

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

                  children: [
                    Text(kAppName, style: context.textFromGoogle(GoogleFonts.rubik).h2),
                    const Spacer(),
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
                child: Stack(
                  children: [
                    Column(
                      spacing: Insets.med,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Login', style: context.text.h3),
                        Text('Enter your email and password to login', style: context.text.muted),
                        const Gap(Insets.sm),
                        ShadInput(
                          placeholder: const Text('Email'),
                          controller: email,
                          leading: const Padding(padding: EdgeInsets.all(4.0), child: Icon(LuIcons.mail)),
                        ),

                        ShadInput(
                          placeholder: const Text('Password'),
                          controller: password,
                          leading: const Padding(padding: EdgeInsets.all(4.0), child: Icon(LuIcons.lock)),
                          obscureText: obscure.value,
                          trailing: ShadButton.ghost(
                            width: 24,
                            height: 24,
                            padding: Pads.zero,
                            decoration: const ShadDecoration(
                              secondaryBorder: ShadBorder.none,
                              secondaryFocusedBorder: ShadBorder.none,
                            ),
                            leading: Icon(obscure.value ? LucideIcons.eyeOff : LucideIcons.eye),
                            onPressed: () => obscure.toggle(),
                          ),
                        ),

                        SubmitButton(
                          width: double.infinity,
                          onPressed: (l) async {
                            l.value = true;
                            final result = await authCtrl().signIn(email.text, password.text);
                            if (context.mounted) result.showToast(context);

                            l.value = false;
                          },
                          child: const Text('Login'),
                        ),

                        const Gap(Insets.sm),
                        Text('By clicking login, you agree to our terms and conditions', style: context.text.muted),

                        Row(
                          children: [
                            ShadButton.outline(
                              child: const Text('Admin'),
                              onPressed: () {
                                email.text = 'admin@gmail.com';
                                password.text = '12341234';
                              },
                            ),
                            if (!kReleaseMode)
                              ShadButton.outline(
                                child: const Text('Tr'),
                                onPressed: () {
                                  email.text = 'tr@t.com';
                                  password.text = '12341234';
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Text(kVersion, style: context.text.muted),
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
