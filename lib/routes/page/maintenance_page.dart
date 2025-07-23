import 'package:pos/features/settings/controller/settings_ctrl.dart';
import 'package:pos/main.export.dart';

class MaintenancePage extends HookConsumerWidget {
  const MaintenancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = useState(false);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Under Maintenance', style: context.text.h3),
            const Gap(5),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: kAppName, style: context.text.large),
                  TextSpan(text: ' is currently under maintenance', style: context.text.p.bold),
                  TextSpan(text: '\n\nPlease come back later', style: context.text.muted),
                ],
              ),
              textAlign: TextAlign.center,
            ),

            const Gap(20),
            ShadButton(
              onPressed: () async {
                loading.truthy();
                await ref.read(configCtrlProvider.notifier).init();
                loading.falsey();
              },
              leading: loading.value ? const Loading(primary: false) : const Icon(LuIcons.refreshCcw),
              child: const SelectionContainer.disabled(child: Text('Reload')),
            ),
          ],
        ),
      ),
    );
  }
}
