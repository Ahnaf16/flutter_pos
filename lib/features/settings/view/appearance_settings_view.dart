import 'package:pos/main.export.dart';

class AppearanceSettingsView extends ConsumerWidget {
  const AppearanceSettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return ShadCard(
      border: const Border(),
      shadows: const [],
      padding: Pads.med(),
      childPadding: Pads.med('t'),
      title: const Text('Appearance Settings'),
      description: const Text('Change the appearance of the app'),
      child: SingleChildScrollView(
        child: Column(
          spacing: Insets.med,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShadInputDecorator(
              label: const Text('Language'),
              child: ShadSelect<AppLocale>(
                initialValue: LocaleSettings.currentLocale,
                minWidth: 250,
                maxWidth: 300,
                placeholder: const Text('Select Language'),
                selectedOptionBuilder: (context, value) => Text(value.name.titleCase),
                itemCount: AppLocale.values.length,
                onChanged: (value) {
                  if (value != null) LocaleSettings.setLocale(value);
                },
                optionsBuilder:
                    (_, i) => ShadOption(value: AppLocale.values[i], child: Text(AppLocale.values[i].name.titleCase)),
              ),
            ),

            const Gap(Insets.med),
            Row(
              spacing: Insets.med,
              children: [
                Flexible(
                  child: ShadInputDecorator(
                    label: const Text('Theme mode'),
                    child: ShadSelect<ThemeMode>(
                      initialValue: theme.mode,
                      minWidth: 250,
                      maxWidth: 300,
                      maxHeight: 150,
                      placeholder: const Text('Select'),
                      selectedOptionBuilder: (context, value) => Text(value.name.titleCase),
                      onChanged: (v) => ref.read(themeProvider.notifier).setMode(v),
                      itemCount: ThemeMode.values.length,
                      optionsBuilder:
                          (_, i) =>
                              ShadOption(value: ThemeMode.values[i], child: Text(ThemeMode.values[i].name.titleCase)),
                    ),
                  ),
                ),
                Flexible(
                  child: ShadInputDecorator(
                    label: const Text('Theme Color'),
                    child: ShadSelect<String>(
                      initialValue: ThemeCtrl.shadThemeColors.first,
                      minWidth: 250,
                      maxWidth: 300,
                      placeholder: const Text('Select'),
                      selectedOptionBuilder: (context, value) {
                        final primary = ShadColorScheme.fromName(value).primary;
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: Insets.sm,
                          children: [ShadCard(backgroundColor: primary, expanded: false), Text(value.titleCase)],
                        );
                      },
                      onChanged: (v) => ref.read(themeProvider.notifier).setTheme(v),
                      itemCount: ThemeCtrl.shadThemeColors.length,
                      optionsBuilder: (_, i) {
                        final name = ThemeCtrl.shadThemeColors[i];
                        final primary = ShadColorScheme.fromName(name).primary;

                        return ShadOption(
                          value: ThemeCtrl.shadThemeColors[i],
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: Insets.sm,
                            children: [ShadCard(backgroundColor: primary, expanded: false), Text(name.titleCase)],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
