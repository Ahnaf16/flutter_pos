import 'package:pos/features/auth/controller/auth_ctrl.dart';
import 'package:pos/main.export.dart';

class NavigationRoot extends HookConsumerWidget {
  const NavigationRoot(this.child, {super.key});
  final Widget child;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = ref.watch(authCtrlProvider);

    final rootPath = context.routeState.uri.pathSegments.first;
    final getIndex = _items.indexWhere((item) => item.$3?.path.contains(rootPath) ?? false);

    final index = useState(0);
    final expanded = useState(true);

    useEffect(() {
      index.value = getIndex;
      return null;
    }, [rootPath]);

    return authUser.when(
      error: (e, s) => ErrorView(e, s, prov: authCtrlProvider),
      loading: () => const SplashPage(),
      data: (user) {
        return Scaffold(appBar: _AppBar(user: user), body: _BODY(expanded: expanded, index: index, child: child));
      },
    );
  }
}

class _AppBar extends HookConsumerWidget implements PreferredSizeWidget {
  const _AppBar({this.user});

  final AppUser? user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeCtrl = useCallback(() => ref.read(themeProvider.notifier));
    final themeMode = ref.watch(themeProvider).mode;

    final popCtrl = useMemoized(ShadPopoverController.new);

    final user = this.user;

    return AppBar(
      title: const Text(kAppName),
      actions: [
        ShadPopover(
          controller: popCtrl,
          padding: Pads.padding(v: Insets.med, h: Insets.lg),
          anchor: const ShadAnchorAuto(offset: Offset(8, 5)),
          popover: (context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (user != null) ...[
                  Row(
                    spacing: Insets.sm,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(user.name, style: context.text.large),
                      ShadButton(onPressed: () {}, child: const Icon(LuIcons.pen)).compact(),
                    ],
                  ),
                  Text(user.email, style: context.text.muted),
                  Text(user.phone, style: context.text.muted),
                  const Gap(Insets.med),

                  ShadButton.ghost(
                    width: 250,
                    padding: Pads.padding(v: Insets.sm, h: Insets.xs),
                    onPressed: () => ref.read(authCtrlProvider.notifier).signOut(),
                    leading: const Icon(LucideIcons.logOut),
                    mainAxisAlignment: MainAxisAlignment.start,
                    child: const Text('Logout'),
                  ),
                ],
                ShadButton.ghost(
                  width: 250,
                  padding: Pads.padding(v: Insets.sm, h: Insets.xs),
                  mainAxisAlignment: MainAxisAlignment.start,
                  onPressed: () => themeCtrl().toggleMode(),
                  leading: Icon(themeMode == ThemeMode.dark ? LucideIcons.sun : LucideIcons.moon),
                  child: Text(themeMode == ThemeMode.dark ? 'Light mode' : 'Dark mode'),
                ),
              ],
            );
          },
          child: GestureDetector(onTap: popCtrl.toggle, child: CircleImage(user?.getPhoto, borderWidth: 1, radius: 20)),
        ),
        const Gap(Insets.med),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _BODY extends StatelessWidget {
  const _BODY({required this.expanded, required this.index, required this.child});

  final ValueNotifier<bool> expanded;
  final ValueNotifier<int> index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ShadSeparator.horizontal(margin: Pads.zero),
        Expanded(
          child: Row(
            children: [
              SingleChildScrollView(
                padding: Pads.med(),
                child: LimitedWidthBox(
                  maxWidth: expanded.value ? 200 : 60,
                  child: IntrinsicWidth(
                    child: Column(
                      spacing: Insets.xs,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final (text, icon, path) in _items)
                          _NavButton(
                            text: text,
                            icon: icon,
                            expanded: expanded.value,
                            selected: index.value == _items.indexOf((text, icon, path)),
                            onTap: () {
                              index.value = _items.indexOf((text, icon, path));
                              if (path != null) path.go(context);
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const ShadSeparator.vertical(margin: Pads.zero),
              Expanded(child: child),
            ],
          ),
        ),
      ],
    );
  }
}

class _NavButton extends HookWidget {
  const _NavButton({required this.text, this.icon, this.onTap, this.selected = false, this.expanded = true});

  final String text;
  final IconData? icon;
  final bool selected;
  final bool expanded;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    if (icon == null && expanded) return DecoContainer(padding: Pads.padding(top: Insets.sm), child: Text(text));

    return ShadButton(
      mainAxisAlignment: MainAxisAlignment.start,
      backgroundColor: selected ? context.colors.primary.op2 : Colors.transparent,
      hoverBackgroundColor: context.colors.primary.op1,
      hoverForegroundColor: context.colors.foreground,
      foregroundColor: context.colors.foreground,
      onPressed: onTap,
      leading: Icon(icon),
      child:
          !expanded
              ? null
              : Flexible(
                child: OverflowMarquee(
                  step: 50,
                  delayDuration: 2.seconds,
                  child: Text(text, overflow: TextOverflow.ellipsis, maxLines: 1),
                ),
              ),
    );
  }
}

List<(String text, IconData? icon, RPath? path)> get _items => [
  ('Home', LuIcons.house, RPaths.home),
  ('Inventory', null, null),
  ('Products', LuIcons.box, RPaths.products),
  ('Stock', LuIcons.arrowUp01, RPaths.stock),
  ('Unit', LuIcons.ruler, RPaths.unit),
  // ('Category', LuIcons.group, RPaths.home),
  // ('Brand', LuIcons.group, RPaths.home),

  // ('', null, null),
  ('Sales', null, null),
  ('Sales History', LuIcons.shoppingCart, RPaths.sales),
  ('Return sales', LuIcons.archiveRestore, RPaths.returnSales),

  // ('', null, null),
  ('Purchases', null, null),
  ('Purchase History', LuIcons.scrollText, RPaths.purchases),
  ('Return purchase', LuIcons.panelBottomClose, RPaths.returnPurchases),

  // ('', null, null),
  ('People', null, null),
  ('Customer', LuIcons.users, RPaths.customer),
  ('Supplier', LuIcons.usersRound, RPaths.supplier),
  ('Staff', LuIcons.userCog, RPaths.staffs),

  // ('', null, null),
  ('Inventory', null, null),
  ('Warehouse', LuIcons.gitBranch, RPaths.warehouse),
  ('Stock Transfer', LuIcons.arrowUpDown, RPaths.stockTransfer),

  // ('', null, null),
  ('Accounting', null, null),
  ('Expense', LuIcons.wallet, RPaths.expense),
  ('Due', LuIcons.coins, RPaths.due),
  // ('Due collection', LuIcons.handCoins, RPaths.home),
  ('Money transfer', LuIcons.arrowsUpFromLine, RPaths.moneyTransfer),
  ('Transactions', LuIcons.landmark, RPaths.transactions),

  // ('', null, null),
  ('Configuration', null, null),
  ('Settings', LuIcons.settings2, RPaths.settings),
];
