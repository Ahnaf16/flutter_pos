import 'package:pos/main.export.dart';

class LanguageView extends HookConsumerWidget {
  const LanguageView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      headers: [AppBar(title: const Text('Language'))],

      child: ListView.separated(
        padding: context.layout.pagePadding,
        itemCount: AppLocale.values.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final locale = AppLocale.values[index];
          final selected = LocaleSettings.currentLocale == locale;

          return CardButton(
            onPressed: () => LocaleSettings.setLocale(locale),
            leading: Avatar(
              backgroundColor: selected ? context.colors.primary : context.colors.card,
              initials: locale.languageCode,
            ),
            child: Text(locale.name),
          );
        },
      ),
    );
  }
}
