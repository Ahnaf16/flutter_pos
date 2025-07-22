import 'package:scaled_app/scaled_app.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'package:pos/main.export.dart';

void main() async {
  ScaledWidgetsFlutterBinding.ensureInitialized(
    scaleFactor: (size) {
      const baseWidth = 1440;
      final factor = size.width / baseWidth;
      return factor.clamp(0.9, 1.0);
    },
  );
  usePathUrlStrategy();
  GoRouter.optionURLReflectsImperativeAPIs = true;

  await initDependencies();

  runApp(const ProviderScope(child: PosApp()));
}

class PosApp extends HookConsumerWidget {
  const PosApp({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final theme = ref.watch(themeProvider);
    final route = ref.watch(routerProvider);

    useEffect(() => null, [theme]);

    return ShadApp.custom(
      theme: theme.theme,
      darkTheme: theme.theme,
      themeMode: theme.mode,
      appBuilder: (context) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: kAppName,
        theme: Theme.of(context),
        darkTheme: Theme.of(context),
        routerConfig: route,
        builder: (context, child) {
          return ShadAppBuilder(child: child, builder: (context, child) => Layouts.init(context, child));
        },
      ),
    );
  }
}
