import 'package:flutter/foundation.dart';
import 'package:pos/features/auth/controller/auth_ctrl.dart';
import 'package:pos/features/home/controller/home_ctrl.dart';
import 'package:pos/features/settings/controller/settings_ctrl.dart';
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

    final selectedValue = useState('DashBoard');
    final drawerOpen = useState(false);
    final isMobile = context.layout.isMobile;

    // useEffect(() {
    //   if (!isMobile) {
    //     final items = navItems(authUser.valueOrNull?.role?.getPermissions ?? []);
    //     selectedValue.value = items.indexWhere((item) => item.$3?.path.contains(rootPath) ?? false);
    //   }
    //   return null;
    // }, [rootPath, authUser.value]);

    return authUser.when(
      error: (e, s) => ErrorView(e, s, prov: authCtrlProvider),
      loading: () => const SplashPage(),
      data: (user) {
        final permissions = user?.role?.getPermissions ?? [];
        return Scaffold(
          appBar: context.layout.isMobile ? null : _AppBar(user: user),
          body: _BODY(
            drawerOpen: drawerOpen,
            selectedValue: selectedValue,
            permissions: permissions,
            child: child,
          ),
        );
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
    final viewingWh = ref.watch(viewingWHProvider);
    final config = ref.watch(configCtrlProvider);
    final houseList = useState(<WareHouse>[]);

    void fetchHouses() async {
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
    }, [user?.id, user?.warehouse?.isDefault]);

    return AppBar(
      title: Row(
        spacing: Insets.lg,
        children: [
          if (config.shop.shopLogo != null) CircleImage(Img.aw(config.shop.shopLogo!), radius: 20),
          Text(config.shop.shopName ?? kAppName),
        ],
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
            initialValue: viewingWh.viewing,
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
              ref.read(viewingWHProvider.notifier).updateHouse(v, null);
            },
            allowDeselection: true,
          ),
        const Gap(Insets.med),
        if (!context.routeState.matchedLocation.contains(RPaths.createSales.path))
          ShadButton(
            leading: const Icon(LuIcons.calculator),
            onPressed: () => RPaths.createSales.pushNamed(context),
            child: const Text('POS'),
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
                  Text(user.name, style: context.text.large),
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
                Text(kVersion, style: context.text.muted.size(12)),
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

class _BODY extends HookConsumerWidget {
  const _BODY({
    required this.drawerOpen,
    required this.selectedValue,
    required this.permissions,
    required this.child,
  });

  final ValueNotifier<bool> drawerOpen;
  final ValueNotifier<String> selectedValue;
  final Widget child;
  final List<RolePermissions> permissions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = navItems(permissions);

    final nav = SingleChildScrollView(
      padding: Pads.med(),
      child: LimitedWidthBox(
        maxWidth: NavigationRoot.expandedPaneSize,
        center: false,
        child: IntrinsicWidth(
          child: ShadAccordion<String>(
            children: [
              Column(
                spacing: Insets.xs,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final MapEntry(key: title, value: item) in items.entries) ...[
                    Text(title, style: context.text.small),
                    ...item.map(
                      (e) => NavButton(
                        label: e.text,
                        icon: e.icon,
                        selected: e.text == selectedValue.value,
                        onPressed: () => selectedValue.value = e.text,
                      ),
                    ),

                    const Gap(Insets.sm),
                  ],
                ],
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
                  if (!context.layout.isMobile) nav,
                  if (!context.layout.isMobile) const ShadSeparator.vertical(margin: Pads.zero),
                  Expanded(child: child),
                ],
              ),
            ),
          ],
        ),
        if (context.layout.isMobile && drawerOpen.value) ShadCard(width: 300, child: nav),
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
  });

  final String label;
  final IconData? icon;
  final bool selected;
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
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
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onPressed,
        onTapDown: (_) => tapDown.value = true,
        onTapCancel: () => tapDown.value = false,
        onTapUp: (_) => tapDown.value = false,
        child: ShadCard(
          // height: 45,
          width: icon != null ? null : NavigationRoot.expandedPaneSize - 20,
          padding: Pads.sm(),
          backgroundColor: color,
          expanded: false,
          border: const Border(),
          shadows: const [],
          rowCrossAxisAlignment: CrossAxisAlignment.center,
          columnMainAxisAlignment: MainAxisAlignment.center,
          childPadding: Pads.med('l'),
          leading: icon == null ? null : Icon(icon),
          child: OverflowMarquee(
            step: 50,
            delayDuration: 2.seconds,
            child: Text(
              label,
              maxLines: 1,
              style: context.text.large,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}

class NestedNav extends ConsumerWidget {
  const NestedNav({
    super.key,
    required this.label,
    this.onPressed,
    required this.children,
    required this.icon,
    required this.selectedValue,
  });

  final String label;
  final IconData icon;
  final Function()? onPressed;
  final List<Widget> children;
  final String selectedValue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = label == selectedValue;
    return DecoContainer(
      color: selected ? context.colors.border : null,
      borderRadius: Corners.med,
      child: ShadAccordionItem<String>(
        value: label,
        padding: Pads.sm(),
        title: Row(
          spacing: Insets.med,
          children: [
            Icon(icon),
            Text(label, maxLines: 1, style: context.text.large),
          ],
        ),
        separator: const Gap(0),
        underlineTitleOnHover: false,
        child: CenterRight(
          child: IntrinsicWidth(
            child: Column(
              spacing: Insets.xs,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}

Map<String, List<NavItem>> navItems(List<RolePermissions> p) {
  return {
    'Main': [
      NavItem(text: 'DashBoard', icon: LuIcons.house, path: RPaths.home),
      NavItem(text: 'New Sale', icon: LuIcons.circlePlus, path: RPaths.createSales),
    ],
    'Inventory': [
      NavItem(text: 'Product', icon: LuIcons.package, path: RPaths.products),
      NavItem(text: 'Unit', icon: LuIcons.weight, path: RPaths.unit),
    ],
    'Contacts': [
      NavItem(
        text: 'Customers',
        icon: LuIcons.users,
        path: RPaths.customer,
        children: [
          NavItem(text: 'All Customers', path: RPaths.customer),
          NavItem(text: 'Due Adjustment', path: RPaths.customerDueManagement),
        ],
      ),
      NavItem(
        text: 'Suppliers',
        icon: LuIcons.building2,
        children: [
          NavItem(text: 'All Suppliers', path: RPaths.supplier),
          NavItem(text: 'Due Clearance', path: RPaths.supplierDueManagement),
        ],
      ),
    ],
  };
}

List<(String text, IconData icon, RPath? path)> _mobileItems(List<RolePermissions> p) {
  return [
    ('Dash', LuIcons.house, RPaths.home),
    if (RolePermissions.isInGroup(p, RolePermissions.inventoryGroup)) ...[
      if (p.contains(RolePermissions.makeSale)) ('POS', LuIcons.shoppingCart, RPaths.createSales),

      if (p.contains(RolePermissions.manageProduct)) ('Products', LuIcons.box, RPaths.products),
    ],

    if (RolePermissions.isInGroup(p, RolePermissions.purchasesGroup)) ...[
      if (p.contains(RolePermissions.makePurchase)) ('Purchase', LuIcons.scrollText, RPaths.purchases),
    ],
    ('More', LuIcons.layoutDashboard, RPaths.moreTools),
  ];
}

class NavItem {
  NavItem({required this.text, this.icon, this.path, this.children = const []});

  final String text;
  final IconData? icon;
  final RPath? path;
  final List<NavItem> children;
}
