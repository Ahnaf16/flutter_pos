import 'package:flutter/foundation.dart';
import 'package:pos/features/auth/controller/auth_ctrl.dart';
import 'package:pos/main.export.dart';

class NavigationRoot extends HookConsumerWidget {
  const NavigationRoot(this.child, {super.key});
  final Widget child;

  static double expandedPaneSize = 200.0;
  static double collapsedPaneSize = 60.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = ref.watch(currentUserProvider);

    final rootPath = context.routeState.uri.pathSegments.first;
    final getIndex = _items.indexWhere((item) => item.$3?.path.contains(rootPath) ?? false);

    final index = useState(0);
    final expanded = useState(true);
    final drawerOpen = useState(false);

    useEffect(() {
      index.value = getIndex;
      return null;
    }, [rootPath]);

    return authUser.when(
      error: (e, s) => ErrorView(e, s, prov: authCtrlProvider),
      loading: () => const SplashPage(),
      data: (user) {
        return Scaffold(
          appBar: _AppBar(
            user: user,
            onLeadingPressed: () {
              if (context.layout.isMobile) drawerOpen.toggle();
              if (!context.layout.isMobile) expanded.toggle();
            },
          ),
          body: _BODY(expanded: expanded, drawerOpen: drawerOpen, index: index, child: child),
        );
      },
    );
  }
}

class _AppBar extends HookConsumerWidget implements PreferredSizeWidget {
  const _AppBar({this.user, this.onLeadingPressed});

  final AppUser? user;
  final VoidCallback? onLeadingPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeCtrl = useCallback(() => ref.read(themeProvider.notifier));
    final themeMode = ref.watch(themeProvider).mode;

    final popCtrl = useMemoized(ShadPopoverController.new);

    final user = this.user;

    return AppBar(
      title: const Text(kAppName),

      leading: UnconstrainedBox(
        child: ShadButton.ghost(
          leading: const Icon(LuIcons.panelRightClose, size: 20),
          onPressed: onLeadingPressed,
          padding: Pads.zero,
        ),
      ),
      scrolledUnderElevation: 0,

      actions: [
        if (!kReleaseMode) ...[
          DefaultTextStyle(
            style: context.text.muted.size(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text(context.layout.deviceSize.name), Text('W: ${context.width}')],
            ),
          ),
          const Gap(Insets.lg),
        ],
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

class _BODY extends HookWidget {
  const _BODY({required this.expanded, required this.drawerOpen, required this.index, required this.child});

  final ValueNotifier<bool> expanded;
  final ValueNotifier<bool> drawerOpen;
  final ValueNotifier<int> index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final navItems = SingleChildScrollView(
      padding: Pads.med(),
      child: LimitedWidthBox(
        maxWidth: expanded.value ? NavigationRoot.expandedPaneSize : NavigationRoot.collapsedPaneSize,
        child: IntrinsicWidth(
          child: Column(
            spacing: Insets.xs,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (text, icon, path) in _items)
                if (!expanded.value && icon == null)
                  const SizedBox.shrink()
                else
                  NavButton(
                    text: text,
                    icon: icon,
                    expanded: expanded.value,
                    selected: index.value == _items.indexOf((text, icon, path)),
                    onPressed: () {
                      index.value = _items.indexOf((text, icon, path));
                      if (path != null) path.go(context);
                    },
                  ),
            ],
          ),
        ),
      ),
    );

    return Stack(
      children: [
        Column(
          children: [
            const ShadSeparator.horizontal(margin: Pads.zero),
            Expanded(
              child: Row(
                children: [
                  if (!context.layout.isMobile) navItems,
                  if (!context.layout.isMobile) const ShadSeparator.vertical(margin: Pads.zero),
                  Expanded(child: child),
                ],
              ),
            ),
          ],
        ),
        if (context.layout.isMobile && drawerOpen.value) ShadCard(width: 300, child: navItems),
      ],
    );
  }
}

class NavButton extends HookWidget {
  const NavButton({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
    this.selected = false,
    this.expanded = true,
  });

  final String text;
  final IconData? icon;
  final bool selected;
  final bool expanded;
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    if (icon == null && expanded) return DecoContainer(padding: Pads.padding(top: Insets.sm), child: Text(text));

    return ShadButton(
      key: ValueKey(text),
      mainAxisAlignment: expanded ? MainAxisAlignment.start : null,
      backgroundColor: selected ? context.colors.primary.op2 : Colors.transparent,
      hoverBackgroundColor: context.colors.primary.op1,
      hoverForegroundColor: context.colors.foreground,
      foregroundColor: context.colors.foreground,
      onPressed: onPressed,
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
  ('Roles', LuIcons.shield, RPaths.roles),

  // ('', null, null),
  ('Inventory', null, null),
  ('Warehouse', LuIcons.gitBranch, RPaths.warehouse),
  ('Stock Transfer', LuIcons.arrowUpDown, RPaths.stockTransfer),

  // ('', null, null),
  ('Accounting', null, null),
  ('Expense', LuIcons.wallet, RPaths.expense),
  ('Due', LuIcons.coins, RPaths.due),
  ('Money transfer', LuIcons.arrowsUpFromLine, RPaths.moneyTransfer),
  ('Transactions', LuIcons.landmark, RPaths.transactions),
  ('Payment Accounts', LuIcons.creditCard, RPaths.paymentAccount),

  // ('', null, null),
  ('Configuration', null, null),
  ('Settings', LuIcons.settings2, RPaths.settings),
];
