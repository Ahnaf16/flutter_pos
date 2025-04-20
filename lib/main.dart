import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:pos/main.export.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  GoRouter.optionURLReflectsImperativeAPIs = true;

  await initDependencies();

  runApp(const ProviderScope(child: PosApp()));
}

class PosApp extends HookConsumerWidget {
  const PosApp({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return ShadcnApp.router(
      debugShowCheckedModeBanner: false,
      title: kAppName,
      routerConfig: ref.watch(routerProvider),
      builder: (context, child) => Layouts.init(context, child),
      themeMode: ThemeMode.light,
      theme: ThemeData(colorScheme: ColorSchemes.lightBlue(), radius: 10),
      darkTheme: ThemeData(colorScheme: ColorSchemes.darkBlue(), radius: 10),
    );
  }
}
