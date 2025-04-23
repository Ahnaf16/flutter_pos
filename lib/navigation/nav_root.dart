import 'package:pos/main.export.dart';

class NavigationRoot extends HookConsumerWidget {
  const NavigationRoot(this.child, {super.key});
  final Widget child;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeCtrl = useCallback(() => ref.read(themeProvider.notifier));
    final themeMode = ref.watch(themeProvider).mode;

    final rootPath = context.routeState.uri.pathSegments.first;

    final index = useState(0);
    final expanded = useState(true);

    useEffect(() {
      // index.value = getIndex;
      return null;
    }, [rootPath]);

    return Scaffold(
      appBar: AppBar(
        title: const Text(kAppName),
        leading: ShadButton.ghost(onPressed: () => expanded.toggle(), child: const Icon(Icons.menu)),
        actions: [
          ShadButton.ghost(
            onPressed: () => themeCtrl().toggleMode(),
            child: Icon(themeMode == ThemeMode.dark ? Icons.dark_mode_rounded : Icons.light_mode_rounded),
          ),
        ],
      ),

      body: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildButton('Home', LuIcons.house),
              buildLabel('Inventory'),
              buildButton('Products', LuIcons.box),
              buildButton('Stock', LuIcons.arrowUp01),
              buildButton('Unit', LuIcons.ruler),
              buildButton('Category', LuIcons.group),
              buildButton('Brand', LuIcons.group),
              const ShadSeparator.horizontal(),

              buildLabel('Sales'),
              buildButton('Sales History', LuIcons.shoppingCart),
              buildButton('Return sales', LuIcons.archiveRestore),
              const ShadSeparator.horizontal(),

              buildLabel('Purchases'),
              buildButton('Purchase History', LuIcons.scrollText),
              buildButton('Return purchase', LuIcons.panelBottomClose),
              const ShadSeparator.horizontal(),

              buildLabel('People'),
              buildButton('Customer', LuIcons.users),
              buildButton('Supplier', LuIcons.usersRound),
              buildButton('Staff', LuIcons.userCog),
              const ShadSeparator.horizontal(),

              buildLabel('Branch'),
              buildButton('Branches', LuIcons.gitBranch),
              buildButton('Stock Transfer', LuIcons.arrowUpDown),
              const ShadSeparator.horizontal(),

              buildLabel('Accounting'),
              buildButton('Expense', LuIcons.wallet),
              buildButton('Expense category', LuIcons.walletCards),
              buildButton('Due', LuIcons.coins),
              buildButton('Due collection', LuIcons.handCoins),
              buildButton('Money transfer', LuIcons.arrowsUpFromLine),
              buildButton('Transactions', LuIcons.landmark),
              const ShadSeparator.horizontal(),

              buildLabel('Configuration'),
              buildButton('Settings', LuIcons.settings2),
            ],
          ),
          const VerticalDivider(),
          Flexible(child: child),
        ],
      ),
    );
  }

  Widget buildButton(String text, IconData icon) {
    return Row(children: [Icon(icon), Text(text)]);
  }

  Widget buildLabel(String label) {
    return Text(label);
  }
}
