import 'package:pos/features/settings/view/appearance_settings_view.dart';
import 'package:pos/features/settings/view/general_settings_view.dart';
import 'package:pos/features/settings/view/profile_view.dart';
import 'package:pos/features/settings/view/shop_settings_view.dart';
import 'package:pos/main.export.dart';

class SettingsView extends HookConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = useState(0);
    final ly = context.layout;

    return BaseBody(
      title: 'Settings',
      padding: Pads.zero,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!ly.isDesktop)
            ShadTabs<int>(
              value: index.value,
              scrollable: true,
              tabBarConstraints: const BoxConstraints(maxWidth: 500),
              tabs: [
                for (int i = 0; i < _paths.length; i++)
                  ShadTab(value: i, onPressed: () => index.value = i, child: Text(_paths[i].$1)),
              ],
            ),
          Padding(
            padding: Pads.med(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Insets.sm,
              children: [
                if (ly.isDesktop)
                  SizedBox(
                    width: 150,
                    child: IntrinsicWidth(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (int i = 0; i < _paths.length; i++)
                            ShadButton.secondary(
                              key: ValueKey(_paths[i].$1),
                              mainAxisAlignment: MainAxisAlignment.start,
                              backgroundColor: i == index.value ? context.colors.primary.op2 : Colors.transparent,
                              hoverBackgroundColor: context.colors.primary.op1,
                              hoverForegroundColor: context.colors.foreground,
                              foregroundColor: context.colors.foreground,
                              leading: Text(_paths[i].$1),
                              onPressed: () => index.value = i,
                            ),
                        ],
                      ),
                    ),
                  ),
                Expanded(child: _paths[index.value].$2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final _paths = [
  ('Profile', const ProfileView()),
  ('General', const GeneralSettingsView()),
  ('Shop', const ShopSettingsView()),
  ('Appearance', const AppearanceSettingsView()),
];
