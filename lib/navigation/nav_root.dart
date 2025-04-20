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
      headers: [
        AppBar(
          title: const Text(kAppName),

          leading: [
            OutlineButton(
              onPressed: () => expanded.toggle(),
              density: ButtonDensity.icon,
              child: const Icon(Icons.menu),
            ),
          ],
          trailing: [
            OutlineButton(
              onPressed: () => themeCtrl().toggleMode(),
              density: ButtonDensity.icon,
              child: Icon(themeMode == ThemeMode.dark ? Icons.dark_mode_rounded : Icons.light_mode_rounded),
            ),
          ],
        ),
        const Divider(),
      ],
      child: Row(
        children: [
          KNavigationRail(
            backgroundColor: context.colors.card,
            labelType: NavigationLabelType.expanded,
            labelPosition: NavigationLabelPosition.end,
            alignment: NavigationRailAlignment.start,
            constraints: const BoxConstraints(minWidth: 200),
            expanded: expanded.value,
            index: index.value,
            onSelected: (v) {
              index.set(v);
            },
            children: [
              buildButton('Home', LuIcons.house),
              buildLabel('Inventory'),
              buildButton('Products', LuIcons.box),
              buildButton('Stock', LuIcons.arrowUp01),
              buildButton('Unit', LuIcons.ruler),
              buildButton('Category', LuIcons.group),
              buildButton('Brand', LuIcons.group),
              const NavigationDivider(),
              buildLabel('Sales'),
              buildButton('Sales History', LuIcons.shoppingCart),
              buildButton('Return sales', LuIcons.archiveRestore),
              const NavigationDivider(),
              buildLabel('Purchases'),
              buildButton('Purchase History', LuIcons.scrollText),
              buildButton('Return purchase', LuIcons.panelBottomClose),
              const NavigationDivider(),
              buildLabel('People'),
              buildButton('Customer', LuIcons.users),
              buildButton('Supplier', LuIcons.usersRound),
              buildButton('Staff', LuIcons.userCog),
              const NavigationDivider(),
              buildLabel('Branch'),
              buildButton('Branches', LuIcons.gitBranch),
              buildButton('Stock Transfer', LuIcons.arrowUpDown),
              const NavigationDivider(),
              buildLabel('Accounting'),
              buildButton('Expense', LuIcons.wallet),
              buildButton('Expense category', LuIcons.walletCards),
              buildButton('Due', LuIcons.coins),
              buildButton('Due collection', LuIcons.handCoins),
              buildButton('Money transfer', LuIcons.arrowsUpFromLine),
              buildButton('Transactions', LuIcons.landmark),
              const NavigationDivider(),
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

  NavigationItem buildButton(String text, IconData icon) {
    return NavigationItem(
      label: Text(text),
      alignment: Alignment.centerLeft,
      selectedStyle: const ButtonStyle.primaryIcon(),
      child: Icon(icon),
    );
  }

  NavigationLabel buildLabel(String label) {
    return NavigationLabel(
      alignment: Alignment.centerLeft,
      child: Text(label).semiBold().muted(),
      // padding: EdgeInsets.zero,
    );
  }
}
