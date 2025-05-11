import 'package:flutter/foundation.dart';
import 'package:pos/features/auth/controller/auth_ctrl.dart';
import 'package:pos/features/home/controller/home_ctrl.dart';
import 'package:pos/features/warehouse/controller/warehouse_ctrl.dart';
import 'package:pos/main.export.dart';

class NavigationRoot extends HookConsumerWidget {
  const NavigationRoot(this.child, {super.key});
  final Widget child;

  static double expandedPaneSize = 200.0;
  static double collapsedPaneSize = 40.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = ref.watch(currentUserProvider);

    final rootPath = context.routeState.uri.pathSegments.first;
    final getIndex = _items.indexWhere((item) => item.$3?.path.contains(rootPath) ?? false);

    final index = useState(0);
    final expanded = useState(true);
    final showLabel = useState(true);
    final drawerOpen = useState(false);

    useEffect(() {
      index.value = getIndex;
      return null;
    }, [rootPath]);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.layout.isDesktop) {
          expanded.value = true;
        } else {
          expanded.value = false;
        }
        Future.delayed(expanded.value ? 250.ms : 0.ms, () {
          showLabel.value = expanded.value;
        });
      });

      return null;
    }, [context.layout.isDesktop]);

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
              Future.delayed(expanded.value ? 250.ms : 0.ms, () {
                showLabel.toggle();
              });
            },
          ),
          body: _BODY(expanded: expanded, showLabel: showLabel, drawerOpen: drawerOpen, index: index, child: child),
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
    final viewingWh = ref.watch(viewingWHProvider);
    final houseList = useState(<WareHouse>[]);

    void fetchHouses() async {
      cat(user?.name ?? 'NA');
      if (user?.warehouse?.isDefault == true) {
        final houses = await ref.read(warehouseCtrlProvider.future);
        houseList.value = houses;
      } else {
        houseList.value = [];
      }
    }

    useEffect(() {
      fetchHouses();
      return null;
    }, [user?.id]);

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
        if (houseList.value.isNotEmpty)
          ShadSelect<WareHouse>(
            maxWidth: 200,
            initialValue: viewingWh,
            placeholder: const Text('All'),
            decoration: ShadDecoration(
              border: ShadBorder.all(),
              secondaryFocusedBorder: ShadBorder.all(color: Colors.transparent),
            ),
            selectedOptionBuilder: (_, v) => Text(v.name),
            options: [
              ...houseList.value.map(
                // ignore: deprecated_member_use
                (e) => ShadOption(value: e, orderPolicy: const OrderPolicy.reverse(), child: Text(e.name)),
              ),
            ],
            onChanged: (v) {
              ref.read(viewingWHProvider.notifier).updateHouse(v);
            },
            allowDeselection: true,
          ),
        const Gap(Insets.lg),
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
  const _BODY({
    required this.expanded,
    required this.showLabel,
    required this.drawerOpen,
    required this.index,
    required this.child,
  });

  final ValueNotifier<bool> expanded;
  final ValueNotifier<bool> showLabel;
  final ValueNotifier<bool> drawerOpen;
  final ValueNotifier<int> index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final navItems = SingleChildScrollView(
      padding: Pads.med(),
      child: LimitedWidthBox(
        maxWidth: expanded.value ? NavigationRoot.expandedPaneSize : NavigationRoot.collapsedPaneSize,
        center: false,
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
                    label: text,
                    icon: icon,
                    showLabel: showLabel.value,
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
                crossAxisAlignment: CrossAxisAlignment.start,
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
    required this.label,
    this.icon,
    this.onPressed,
    this.selected = false,
    this.showLabel = true,
    this.expanded = false,
  });

  final String label;
  final IconData? icon;
  final bool selected;
  final bool showLabel;
  final bool expanded;
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    if (icon == null && expanded) {
      return DecoContainer(
        padding: Pads.padding(top: Insets.sm),
        child: Text(label, maxLines: 1).animate().fadeIn(duration: 250.ms),
      );
    }

    Widget? child;

    if (showLabel) {
      child = OverflowMarquee(
        step: 50,
        delayDuration: 2.seconds,
        child: Text(label, overflow: TextOverflow.ellipsis, maxLines: 1),
      ).animate().fadeIn(duration: 100.ms);
    } else {
      child = null;
    }

    final hovered = useState(false);
    final tapDown = useState(false);

    Color color = selected ? context.colors.primary.op2 : Colors.transparent;

    if (hovered.value) {
      color = selected ? context.colors.primary.op3 : context.colors.border;
    }
    if (tapDown.value) {
      color = context.colors.primary.op3;
    }

    return MouseRegion(
      onEnter: (_) => hovered.value = true,
      onExit: (_) => hovered.value = false,
      child: GestureDetector(
        onTap: onPressed,
        onTapDown: (_) => tapDown.value = true,
        onTapCancel: () => tapDown.value = false,
        onTapUp: (_) => tapDown.value = false,
        child: ShadCard(
          height: 45,
          padding: Pads.med(),
          backgroundColor: color,
          expanded: false,
          border: const Border(),
          shadows: const [],
          rowCrossAxisAlignment: CrossAxisAlignment.center,
          columnMainAxisAlignment: MainAxisAlignment.center,
          childPadding: Pads.med('l'),
          leading: Icon(icon),
          child: child,
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
  ('Sales Return', LuIcons.shoppingCart, RPaths.salesReturn),

  // ('', null, null),
  ('Purchases', null, null),
  ('Purchase History', LuIcons.scrollText, RPaths.purchases),
  ('Purchase Return', LuIcons.scrollText, RPaths.purchasesReturn),

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
  ('Expense Category', LuIcons.variable, RPaths.expenseCategory),
  ('Due', LuIcons.coins, RPaths.due),
  ('Money transfer', LuIcons.arrowsUpFromLine, RPaths.moneyTransfer),
  ('Transactions', LuIcons.landmark, RPaths.transactions),
  ('Payment Accounts', LuIcons.creditCard, RPaths.paymentAccount),

  // ('', null, null),
  ('Configuration', null, null),
  ('Settings', LuIcons.settings2, RPaths.settings),
];
