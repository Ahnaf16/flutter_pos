import 'package:pos/main.export.dart';

class NavigationRoot extends HookConsumerWidget {
  const NavigationRoot(this.child, {super.key});
  final Widget child;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rootPath = context.routeState.uri.pathSegments.first;

    final index = useState(0);

    useEffect(() {
      // index.value = getIndex;
      return null;
    }, [rootPath]);

    return Scaffold(child: child);
  }
}
