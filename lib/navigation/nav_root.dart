import 'package:flutter/foundation.dart';
import 'package:pos/features/auth/controller/auth_ctrl.dart';
import 'package:pos/features/home/controller/home_ctrl.dart';
import 'package:pos/features/settings/controller/settings_ctrl.dart';
import 'package:pos/features/warehouse/controller/warehouse_ctrl.dart';
import 'package:pos/main.export.dart';

class NavigationRoot extends HookConsumerWidget {
  const NavigationRoot(this.child, {super.key});
  final Widget child;

  static double expandedPaneSize = 220.0;
  // static double collapsedPaneSize = 40.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = ref.watch(currentUserProvider);

    final rootPath = context.routeState.uri.pathSegments.first;

    final selectedValue = useState('DashBoard');
    final isDesk = context.layout.isDesktop;

    useEffect(() {
      if (isDesk) {
        final items = navItems(authUser.valueOrNull?.role?.getPermissions ?? []);
        final selected = items.values
            .expand((e) => e.expand((x) => x.children))
            .firstWhereOrNull((x) => x.path?.name == rootPath)
            ?.text;

        selectedValue.value = selected ?? 'DashBoard';
      }
      return null;
    }, [rootPath, authUser.value]);

    return authUser.when(
      error: (e, s) => ErrorView(e, s, prov: authCtrlProvider),
      loading: () => const SplashPage(),
      data: (user) {
        final permissions = user?.role?.getPermissions ?? [];
        return Scaffold(
          appBar: isDesk
              ? _AppBar(user: user)
              : AppBar(
                  scrolledUnderElevation: 0,
                  actions: [
                    if (!context.routeState.matchedLocation.contains(RPaths.createSales.path))
                      ShadButton(
                        leading: const Icon(LuIcons.calculator),
                        onPressed: () => RPaths.createSales.pushNamed(context),
                        child: const Text('POS'),
                      ),
                    const Gap(10),
                  ],
                ),
          drawer: isDesk ? null : NavItemWIdget(selectedValue: selectedValue, permissions: permissions),
          body: _BODY(selectedValue: selectedValue, permissions: permissions, child: child),
        );
      },
    );
  }
}

class NavItemWIdget extends ConsumerWidget {
  const NavItemWIdget({super.key, required this.selectedValue, required this.permissions});
  final ValueNotifier<String> selectedValue;
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
                      (e) {
                        if (e.children.isNotEmpty) {
                          return NestedNav(
                            label: e.text,
                            icon: e.icon,
                            selected: e.children.any((e) => e.text == selectedValue.value),
                            children: [
                              for (final child in e.children)
                                NavButton(
                                  label: child.text,
                                  selected: child.text == selectedValue.value,
                                  onPressed: () {
                                    selectedValue.value = child.text;
                                    child.path?.goNamed(context);
                                  },
                                ),
                            ],
                          );
                        }
                        return NavButton(
                          label: e.text,
                          icon: e.icon,
                          selected: e.text == selectedValue.value,
                          onPressed: () {
                            selectedValue.value = e.text;
                            e.path?.goNamed(context);
                          },
                        );
                      },
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

    if (!context.layout.isDesktop) {
      return Drawer(
        shape: const RoundedRectangleBorder(),
        child: nav,
      );
    }

    return nav;
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
      // cat('');
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
                    child: const SelectionContainer.disabled(child: Text('Logout')),
                  ),
                ],
                ShadButton.ghost(
                  width: 250,
                  padding: Pads.padding(v: Insets.sm, h: Insets.xs),
                  mainAxisAlignment: MainAxisAlignment.start,
                  onPressed: () => themeCtrl().toggleMode(),
                  leading: Icon(themeMode == ThemeMode.dark ? LucideIcons.sun : LucideIcons.moon),
                  child: SelectionContainer.disabled(
                    child: Text(themeMode == ThemeMode.dark ? 'Light mode' : 'Dark mode'),
                  ),
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
    required this.selectedValue,
    required this.permissions,
    required this.child,
  });

  final ValueNotifier<String> selectedValue;
  final List<RolePermissions> permissions;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        Column(
          children: [
            const ShadSeparator.horizontal(margin: Pads.zero),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (context.layout.isDesktop) NavItemWIdget(selectedValue: selectedValue, permissions: permissions),
                  if (context.layout.isDesktop) const ShadSeparator.vertical(margin: Pads.zero),
                  Expanded(child: child),
                ],
              ),
            ),
          ],
        ),
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
          width: icon != null ? null : NavigationRoot.expandedPaneSize,
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
              style: context.text.small,
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
    required this.selected,
  });

  final String label;
  final IconData? icon;
  final Function()? onPressed;
  final List<Widget> children;
  final bool selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DecoContainer(
      color: selected ? context.colors.border.op5 : null,
      borderRadius: Corners.med,
      child: ShadAccordionItem<String>(
        value: label,
        padding: Pads.sm(),
        title: Row(
          spacing: Insets.med,
          children: [
            Icon(icon),
            Text(label, maxLines: 1, style: context.text.small),
          ],
        ),
        separator: const Gap(0),
        underlineTitleOnHover: false,
        child: CenterRight(
          child: IntrinsicWidth(
            child: Column(
              spacing: Insets.xs,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children.map((e) => Padding(padding: Pads.sm('lr'), child: e)).toList(),
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
      if (p.contains(RolePermissions.makeSale))
        NavItem(text: 'New Sale', icon: LuIcons.circlePlus, path: RPaths.createSales),
      if (p.contains(RolePermissions.makePurchase))
        NavItem(text: 'New Purchase', icon: LuIcons.circlePlus, path: RPaths.createPurchases),
    ],

    if (RolePermissions.isInGroup(p, RolePermissions.inventoryGroup))
      'Inventory': [
        if (p.contains(RolePermissions.manageProduct))
          NavItem(text: 'Product', icon: LuIcons.package, path: RPaths.products),
        if (p.contains(RolePermissions.manageUnit)) NavItem(text: 'Unit', icon: LuIcons.weight, path: RPaths.unit),
      ],

    if (RolePermissions.isInGroup(p, RolePermissions.salesPurchasesGroup))
      'Sales & Purchases': [
        if (RolePermissions.isInGroup(p, RolePermissions.salesGroup))
          NavItem(
            text: 'Sales',
            icon: LuIcons.chartColumn,
            children: [
              if (p.contains(RolePermissions.makeSale)) NavItem(text: 'Sales history', path: RPaths.sales),
              if (p.contains(RolePermissions.returnSale)) NavItem(text: 'Sales return', path: RPaths.salesReturn),
            ],
          ),
        if (RolePermissions.isInGroup(p, RolePermissions.purchasesGroup))
          NavItem(
            text: 'Purchase',
            icon: LuIcons.receipt,
            children: [
              if (p.contains(RolePermissions.makePurchase)) NavItem(text: 'Purchase history', path: RPaths.purchases),
              if (p.contains(RolePermissions.returnPurchase))
                NavItem(text: 'Purchase return', path: RPaths.purchasesReturn),
            ],
          ),
      ],
    if (RolePermissions.isInGroup(p, RolePermissions.contactsGroup))
      'Contacts': [
        if (p.contains(RolePermissions.manageCustomer))
          NavItem(
            text: 'Customers',
            icon: LuIcons.users,
            children: [
              NavItem(text: 'All Customers', path: RPaths.customer),
              NavItem(text: 'Transfer money', path: RPaths.customerMoneyTransfer),
              NavItem(text: 'Due Adjustment', path: RPaths.customerDueManagement),
            ],
          ),
        if (p.contains(RolePermissions.manageSupplier))
          NavItem(
            text: 'Suppliers',
            icon: LuIcons.building2,
            children: [
              NavItem(text: 'All Suppliers', path: RPaths.supplier),
              NavItem(text: 'Due Clearance', path: RPaths.supplierDueManagement),
            ],
          ),
      ],

    if (RolePermissions.isInGroup(p, RolePermissions.teamsGroup))
      'Team': [
        NavItem(
          text: 'Staff Management',
          icon: LuIcons.users,
          children: [
            if (p.contains(RolePermissions.manageStaff)) NavItem(text: 'All Staff', path: RPaths.staffs),
            if (p.contains(RolePermissions.manageRole)) NavItem(text: 'Role & Permissions', path: RPaths.roles),
          ],
        ),
      ],

    if (RolePermissions.isInGroup(p, RolePermissions.logisticsGroup))
      'Logistics': [
        if (p.contains(RolePermissions.manageWarehouse))
          NavItem(text: 'Warehouse', icon: LuIcons.warehouse, path: RPaths.warehouse),
        if (p.contains(RolePermissions.transferStock))
          NavItem(
            text: 'Stock',
            icon: LuIcons.truck,
            children: [
              NavItem(text: 'Stock transfer', path: RPaths.stockTransfer),
              NavItem(text: 'Stock Logs', path: RPaths.stockLog),
            ],
          ),
      ],
    if (RolePermissions.isInGroup(p, RolePermissions.accountingGroup))
      'Accounting': [
        NavItem(
          text: 'Accounts',
          icon: LuIcons.creditCard,
          children: [
            if (p.contains(RolePermissions.manageAccounts))
              NavItem(text: 'Payment Accounts', path: RPaths.paymentAccount),
            NavItem(text: 'Transactions', path: RPaths.transactions),
          ],
        ),
        if (p.contains(RolePermissions.manageExpanse))
          NavItem(
            text: 'Expense',
            icon: LuIcons.dollarSign,
            children: [
              NavItem(text: 'All Expenses', path: RPaths.expense),
              NavItem(text: 'Category', path: RPaths.expenseCategory),
            ],
          ),
        if (p.contains(RolePermissions.due))
          NavItem(text: 'Due Management', icon: LuIcons.calculator, path: RPaths.due),
      ],
    'System': [
      NavItem(text: 'Settings', icon: LuIcons.settings, path: RPaths.settings),
    ],
  };
}

class NavItem {
  NavItem({required this.text, this.icon, this.path, this.children = const []});

  final String text;
  final IconData? icon;
  final RPath? path;
  final List<NavItem> children;

  @override
  String toString() {
    return text;
  }
}
