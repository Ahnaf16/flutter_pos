import 'package:pos/main.export.dart';

class LanguageView extends HookConsumerWidget {
  const LanguageView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Language')),

      body: ListView.separated(
        padding: context.layout.pagePadding,
        itemCount: AppLocale.values.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final locale = AppLocale.values[index];
          final selected = LocaleSettings.currentLocale == locale;

          return GestureDetector(
            onTap: () => LocaleSettings.setLocale(locale),
            child: ShadCard(
              leading: CircleAvatar(
                backgroundColor: selected ? context.colors.primary : context.colors.card,
                child: Text(locale.languageCode),
              ),
              child: Text(locale.name),
            ),
          );
        },
      ),
    );
  }
}
