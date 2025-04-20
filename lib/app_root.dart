import 'main.export.dart';

class AppRoot extends HookConsumerWidget {
  const AppRoot({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      Future.delayed(0.seconds, () {});
      return () {
        cat('>> AppROOT DISPOSE', 'AppROOT');
      };
    }, const []);

    return child;
  }
}
