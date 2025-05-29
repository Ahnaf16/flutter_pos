import 'package:navigator_resizable/navigator_resizable.dart';
import 'package:pos/features/filter/controller/filter_ctrl.dart';
import 'package:pos/features/filter/view/filter_tile.dart';
import 'package:pos/features/filter/view/filterer_body.dart';
import 'package:pos/main.export.dart';

void _push(BuildContext context, Widget child) =>
    Navigator.push(context, ResizableMaterialPageRoute(builder: (context) => child));

class FilterBar extends HookConsumerWidget {
  const FilterBar({
    super.key,
    this.accounts = const [],
    this.houses = const [],
    this.types = const [],
    this.units = const [],
    this.statuses = const [],
    this.roles = const [],
    this.showDateRange = false,
    this.onSearch,
    this.onReset,
    this.hintText,
  });

  final List<PaymentAccount> accounts;
  final List<WareHouse> houses;
  final List<TransactionType> types;
  final List<ProductUnit> units;
  final List<InventoryStatus> statuses;
  final List<UserRole> roles;

  final bool showDateRange;
  final Function(String q)? onSearch;
  final VoidCallback? onReset;
  final String? hintText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final popCtrl = useMemoized(ShadPopoverController.new);
    final searchCtrl = useTextEditingController();

    final fState = ref.watch(filterCtrlProvider);
    final ctrl = useCallback(() => ref.read(filterCtrlProvider.notifier));

    return Column(
      spacing: Insets.xs,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (onSearch != null)
              LimitedWidthBox(
                maxWidth: 450,
                child: ShadTextField(
                  controller: searchCtrl,
                  hintText: hintText ?? 'Search',
                  leading: const Icon(LuIcons.search),
                  onChanged: (v) => onSearch?.call((v ?? '').low),
                  showClearButton: true,
                ),
              ),
            ShadPopover(
              controller: popCtrl,
              padding: Pads.sm(),
              anchor: const ShadAnchorAuto(targetAnchor: Alignment.bottomRight, offset: Offset(13, 0)),
              popover: (context) {
                return _PopOverWidget(
                  builder: (context) => FiltererBody(
                    children: [
                      if (types.isNotEmpty)
                        FilterTile(
                          leading: FilterType.type.icon,
                          text: 'Types',
                          onPressed: () {
                            _push(
                              context,
                              _ListItemBuilder<TransactionType>(
                                title: 'Transaction types',
                                values: types,
                                nameBuilder: (value) => value.name,
                                isSelected: (fState, type) => fState.trxTypes.contains(type),
                                onSelect: (value) => ctrl().copyWith(trxTypes: (s) => {...s, value}.toList()),
                                onRemove: (value) =>
                                    ctrl().copyWith(trxTypes: (s) => s.whereNot((e) => e == value).toList()),
                              ),
                            );
                          },
                        ),

                      if (statuses.isNotEmpty)
                        FilterTile(
                          leading: FilterType.status.icon,
                          text: 'Status',
                          onPressed: () {
                            _push(
                              context,
                              _ListItemBuilder<InventoryStatus>(
                                title: 'Status',
                                values: statuses,
                                nameBuilder: (value) => value.name,
                                isSelected: (fState, type) => fState.statuses.contains(type),
                                onSelect: (value) => ctrl().copyWith(statuses: (s) => {...s, value}.toList()),
                                onRemove: (value) =>
                                    ctrl().copyWith(statuses: (s) => s.whereNot((e) => e == value).toList()),
                              ),
                            );
                          },
                        ),

                      if (accounts.isNotEmpty)
                        FilterTile(
                          leading: FilterType.account.icon,
                          text: 'Accounts',
                          onPressed: () {
                            _push(
                              context,
                              _ListItemBuilder<PaymentAccount>(
                                title: 'Accounts',
                                values: accounts,
                                nameBuilder: (value) => value.name,
                                isSelected: (fState, type) => fState.accounts.contains(type),
                                onSelect: (value) => ctrl().copyWith(accounts: (s) => {...s, value}.toList()),
                                onRemove: (value) =>
                                    ctrl().copyWith(accounts: (s) => s.whereNot((e) => e == value).toList()),
                              ),
                            );
                          },
                        ),

                      if (houses.isNotEmpty)
                        FilterTile(
                          leading: FilterType.house.icon,
                          text: 'Warehouse',
                          onPressed: () {
                            _push(
                              context,
                              _ListItemBuilder<WareHouse>(
                                title: 'Warehouse',
                                values: houses,
                                nameBuilder: (value) => value.name,
                                isSelected: (fState, type) => fState.houses.contains(type),
                                onSelect: (value) => ctrl().copyWith(houses: (s) => {...s, value}.toList()),
                                onRemove: (value) =>
                                    ctrl().copyWith(houses: (s) => s.whereNot((e) => e == value).toList()),
                              ),
                            );
                          },
                        ),

                      if (roles.isNotEmpty)
                        FilterTile(
                          leading: FilterType.roles.icon,
                          text: 'Roles',
                          onPressed: () {
                            _push(
                              context,
                              _ListItemBuilder<UserRole>(
                                title: 'Roles',
                                values: roles,
                                nameBuilder: (value) => value.name,
                                isSelected: (fState, type) => fState.roles.contains(type),
                                onSelect: (value) => ctrl().copyWith(roles: (s) => {...s, value}.toList()),
                                onRemove: (value) =>
                                    ctrl().copyWith(roles: (s) => s.whereNot((e) => e == value).toList()),
                              ),
                            );
                          },
                        ),

                      if (units.isNotEmpty)
                        FilterTile(
                          leading: FilterType.unit.icon,
                          text: 'Product unit',
                          onPressed: () {
                            _push(
                              context,
                              _ListItemBuilder<ProductUnit>(
                                title: 'Product unit',
                                values: units,
                                nameBuilder: (value) => value.name,
                                isSelected: (fState, type) => fState.units.contains(type),
                                onSelect: (value) => ctrl().copyWith(units: (s) => {...s, value}.toList()),
                                onRemove: (value) =>
                                    ctrl().copyWith(units: (s) => s.whereNot((e) => e == value).toList()),
                              ),
                            );
                          },
                        ),

                      if (showDateRange)
                        FilterTile(
                          leading: FilterType.dateFrom.icon,
                          text: 'Date range',
                          onPressed: () {
                            _push(
                              context,
                              const _DateSelector(),
                            );
                          },
                        ),
                    ],
                  ),
                );
              },
              child: ShadButton.outline(
                leading: const Icon(LuIcons.funnel),
                child: const Text('Filter'),
                onPressed: () => popCtrl.toggle(),
              ),
            ),

            ShadIconButton.outline(
              backgroundColor: context.colors.destructive.op1,
              foregroundColor: context.colors.destructive,
              hoverBackgroundColor: context.colors.destructive.op2,
              hoverForegroundColor: context.colors.destructive,
              pressedBackgroundColor: context.colors.destructive.op3,
              icon: const Icon(LuIcons.refreshCw),
              onPressed: () {
                ctrl().reset();
                searchCtrl.clear();
                onReset?.call();
              },
            ),
          ],
        ),
        Wrap(
          spacing: Insets.sm,
          runSpacing: Insets.xs,
          children: [
            for (final MapEntry(:key, :value) in fState.buildNames().entries)
              ShadCard(
                expanded: false,
                backgroundColor: context.colors.secondary,
                radius: Corners.circleBorder,
                height: 36,
                padding: Pads.padding(h: 12, v: 3),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: Insets.sm,
                  children: [
                    Icon(key.icon, color: context.colors.foreground.op5),
                    Text(key.title, style: context.text.muted),
                    ShadSeparator.vertical(color: context.colors.foreground.op5, margin: Pads.xs('tb')),
                    Text(value, style: context.text.p.primary(context)),
                    ShadIconButton.destructive(
                      width: 25,
                      height: 25,
                      backgroundColor: context.colors.secondary,
                      foregroundColor: context.colors.destructive,
                      hoverForegroundColor: context.colors.destructive,
                      hoverBackgroundColor: context.colors.destructive.op1,
                      decoration: const ShadDecoration(
                        secondaryBorder: ShadBorder.none,
                        secondaryFocusedBorder: ShadBorder.none,
                      ),

                      icon: const Icon(LucideIcons.x),
                      onPressed: () => ctrl().clearByType(key),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const Gap(Insets.xs),
      ],
    );
  }
}

class _ListItemBuilder<T> extends HookConsumerWidget {
  const _ListItemBuilder({
    required this.values,
    required this.nameBuilder,
    required this.isSelected,
    required this.onSelect,
    required this.onRemove,
    this.title,
  });

  final String? title;
  final List<T> values;
  final String Function(T value) nameBuilder;
  final bool Function(FilterState state, T value) isSelected;
  final Function(T value) onSelect;
  final Function(T value) onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fState = ref.watch(filterCtrlProvider);

    return FiltererBody(
      showBack: true,
      title: title,
      children: [
        for (final type in values)
          FilterTileSelectable<T>(
            value: type,
            text: nameBuilder(type).titleCase,
            selected: isSelected(fState, type),
            onPressed: () {
              if (!isSelected(fState, type)) return onSelect(type);
              onRemove(type);
            },
          ),
      ],
    );
  }
}

class _DateSelector extends HookConsumerWidget {
  const _DateSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fState = ref.watch(filterCtrlProvider);
    final ctrl = useCallback(() => ref.read(filterCtrlProvider.notifier));

    final from = useState<DateTime?>(fState.from);
    final to = useState<DateTime?>(fState.to);

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: Insets.med,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: Insets.sm,
          children: [
            ShadCard(
              expanded: false,
              title: Text('From', style: context.text.p),
              childPadding: Pads.sm('t'),
              padding: Pads.sm('lrb'),
              child: ShadCalendar(
                decoration: ShadDecoration.none,
                selected: from.value,
                onChanged: (value) {
                  if (value != null && to.value != null && value.isAfterOrEqualTo(to.value!)) {
                    to.value = null;
                  }
                  from.value = value;
                },
              ),
            ),
            AbsorbPointer(
              absorbing: from.value == null,
              child: AnimatedOpacity(
                duration: 250.ms,
                opacity: from.value == null ? .5 : 1,
                child: ShadCard(
                  expanded: false,
                  childPadding: Pads.sm('t'),
                  padding: Pads.sm('lrb'),
                  title: Text('To', style: context.text.p),
                  child: ShadCalendar(
                    decoration: ShadDecoration.none,
                    selectableDayPredicate: (day) {
                      if (from.value == null) return true;
                      return day.isAfter(from.value!);
                    },
                    allowDeselection: true,
                    selected: to.value,
                    onChanged: (value) => to.value = value,
                  ),
                ),
              ),
            ),
          ],
        ),

        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: Insets.sm,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ShadButton.outline(
              height: 35,
              decoration: const ShadDecoration(
                secondaryFocusedBorder: ShadBorder.none,
                secondaryBorder: ShadBorder.none,
              ),
              child: const Text('Cancel'),
              onPressed: () => context.nPop(),
            ),
            ShadButton(
              height: 35,
              decoration: const ShadDecoration(
                secondaryFocusedBorder: ShadBorder.none,
                secondaryBorder: ShadBorder.none,
              ),
              child: const Text('Submit'),
              onPressed: () {
                ctrl().copyWith(
                  from: from.value == null ? null : () => from.value,
                  to: to.value == null ? null : () => to.value,
                );
                context.nPop();
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _PopOverWidget extends StatelessWidget {
  const _PopOverWidget({
    required this.builder,
  });

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return NavigatorResizable(
      child: Navigator(
        onGenerateInitialRoutes: (_, __) => [
          ResizableMaterialPageRoute(builder: builder),
        ],
      ),
    );
  }
}
