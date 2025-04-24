import 'package:flutter_web_plugins/url_strategy.dart';
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
    final theme = ref.watch(themeProvider);
    final route = ref.watch(routerProvider);

    useEffect(() => null, [theme]);

    return ShadApp.materialRouter(
      title: kAppName,
      routerConfig: route,
      themeMode: theme.mode,
      theme: theme.theme,
      darkTheme: theme.theme,
      builder: (context, child) => Layouts.init(context, child),
    );
  }
}
