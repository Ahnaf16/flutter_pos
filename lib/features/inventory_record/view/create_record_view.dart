import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:pos/features/auth/controller/auth_ctrl.dart';
import 'package:pos/features/home/controller/home_ctrl.dart';
import 'package:pos/features/inventory_record/controller/record_editing_ctrl.dart';
import 'package:pos/features/parties/controller/parties_ctrl.dart';
import 'package:pos/features/parties/view/parties_view.dart';
import 'package:pos/features/payment_accounts/controller/payment_accounts_ctrl.dart';
import 'package:pos/features/products/controller/products_ctrl.dart';
import 'package:pos/features/settings/controller/settings_ctrl.dart';
import 'package:pos/features/warehouse/controller/warehouse_ctrl.dart';
import 'package:pos/main.export.dart';

class CreateRecordView extends HookConsumerWidget {
  const CreateRecordView({super.key, required this.type});
  final RecordType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final record = ref.watch(recordEditingCtrlProvider(type));
    final recordCtrl = useCallback(() => ref.read(recordEditingCtrlProvider(type).notifier));
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());

    // final isSale = type == RecordType.sale;

    return BaseBody(
      title: type.name.titleCase,
      padding: context.layout.pagePadding.copyWith(top: 5, bottom: 15),
      body: FormBuilder(
        key: formKey,
        onChanged: () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final state = formKey.currentState!..saveAndValidate();
            recordCtrl().setInputsFromMap(state.instantValue);
          });
        },
        child: user.when(
          loading: () => const Loading(),
          error: (e, s) => ErrorView(e, s, prov: currentUserProvider),
          data: (user) {
            return ShadCard(
              padding: Pads.zero,
              child: ShadResizablePanelGroup(
                showHandle: true,
                children: [
                  ShadResizablePanel(
                    id: 0,
                    defaultSize: .65,
                    child: Column(
                      spacing: Insets.sm,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //! Parti
                        _PartiSection(
                          record: record,
                          onSelect: (p, wi) {
                            recordCtrl().changeParti(p, wi);
                            formKey.currentState?.fields['due_balance']?.reset();
                          },
                        ),
                        const ShadSeparator.horizontal(margin: Pads.zero),
                        Expanded(
                          child: ShadResizablePanelGroup(
                            axis: Axis.vertical,
                            showHandle: true,
                            children: [
                              //! selected products
                              ShadResizablePanel(
                                id: 2,
                                defaultSize: 0.7,
                                child: Padding(
                                  padding: Pads.sm('b'),
                                  child: ListView.separated(
                                    padding: Pads.med('blr'),
                                    itemCount: record.details.length,
                                    separatorBuilder: (_, _) => const ShadSeparator.horizontal(),
                                    itemBuilder: (BuildContext context, int index) {
                                      final detail = record.details[index];
                                      return _ProductTile(
                                        detail: detail,
                                        index: index,
                                        type: type,
                                        onChange: (p, q) {
                                          recordCtrl().changeQuantity(detail, (_) => q);
                                          recordCtrl().updatePrice(detail, p);
                                        },
                                        onProductRemove: (pId) => recordCtrl().removeProduct(pId, detail.stock.id),
                                      );
                                    },
                                  ),
                                ),
                              ),

                              //! calculations
                              ShadResizablePanel(
                                id: 3,
                                defaultSize: 0.3,
                                minSize: 0.2,
                                child: SingleChildScrollView(
                                  padding: Pads.sm(),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    spacing: Insets.sm,
                                    children: [
                                      //! inputs
                                      Expanded(
                                        flex: 2,
                                        child: _Inputs(
                                          record: record,

                                          onTypeChange: recordCtrl().changeDiscountType,
                                          onAccountSelect: recordCtrl().changeAccount,
                                        ),
                                      ),
                                      const SizedBox(height: 200, child: ShadSeparator.vertical(margin: Pads.zero)),

                                      //! summary
                                      Expanded(
                                        child: _Summary(
                                          record: record,

                                          onSubmit: () async {
                                            final res = await recordCtrl().submit();

                                            if (context.mounted) res.showToast(context);

                                            if (res.success) {
                                              formKey.currentState?.reset();
                                              if (context.mounted) context.nPop();
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  //! Products list
                  ShadResizablePanel(
                    id: 1,
                    defaultSize: .35,
                    minSize: .2,
                    maxSize: .4,
                    child: ProductsPanel(
                      type: type,
                      userHouse: user?.warehouse,
                      onProductSelect: recordCtrl().addProduct,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Inputs extends HookConsumerWidget {
  const _Inputs({required this.onTypeChange, required this.record, required this.onAccountSelect});

  final InventoryRecordState record;
  final Function(DiscountType type) onTypeChange;
  final Function(PaymentAccount? acc) onAccountSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final type = record.type;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Insets.sm,
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: ShadTextField(
                name: 'amount',
                hintText: type.isSale ? 'Payment amount' : 'Paid',
                keyboardType: TextInputType.number,
                numeric: true,
              ),
            ),
            Expanded(
              child: ShadTextField(name: 'vat', hintText: 'Vat', keyboardType: TextInputType.number, numeric: true),
            ),
          ],
        ),

        Row(
          children: [
            Expanded(
              flex: 4,
              child: ShadTextField(
                name: 'discount',
                hintText: 'Discount',
                padding: kDefInputPadding.copyWith(bottom: 0, top: 0, right: 5),
                keyboardType: TextInputType.number,
                numeric: true,
                trailing: _DiscountTypePopOver(onTypeChange: onTypeChange, type: record.discountType),
              ),
            ),
            Expanded(
              flex: 3,
              child: ShadTextField(
                name: 'shipping',
                hintText: 'Shipping',
                keyboardType: TextInputType.number,
                numeric: true,
              ),
            ),
          ],
        ),
        Row(
          children: [
            if (type.isSale && record.partiHasBalance)
              Expanded(
                child: ShadInputDecorator(
                  label: const Text('Use Balance'),
                  child: ShadTextField(
                    name: 'due_balance',
                    hintText: 'Use Balance',
                    initialValue: '0',
                    keyboardType: TextInputType.number,
                    numeric: true,
                    validators: [
                      if (record.partiHasBalance)
                        FormBuilderValidators.max(
                          record.parti?.due.abs() ?? 0,
                          errorText: 'This can\'t be more than available balance',
                          checkNullOrEmpty: false,
                        ),
                    ],
                  ),
                ),
              )
            else if (type.isPurchase && record.partiHasDue)
              Expanded(
                child: ShadInputDecorator(
                  label: const Text('Use due'),
                  child: ShadTextField(
                    name: 'due_balance',
                    hintText: 'Use due',
                    keyboardType: TextInputType.number,
                    numeric: true,
                    validators: [
                      if (record.partiHasDue)
                        FormBuilderValidators.max(
                          record.parti?.due.abs() ?? 0,
                          errorText: 'This can\'t be more than parti\'s due',
                          checkNullOrEmpty: false,
                        ),
                    ],
                  ),
                ),
              ),
            Expanded(child: _AccountSelect(onAccountSelect: onAccountSelect, type: type)),
          ],
        ),
      ],
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.record, required this.onSubmit});

  final InventoryRecordState record;
  final FVoid Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    final type = record.type;
    return Padding(
      padding: Pads.sm('tl'),
      child: Column(
        spacing: Insets.sm,
        children: [
          SpacedText(left: 'Subtotal', right: record.subtotal().currency(), styleBuilder: (l, r) => (l, r.bold)),
          SpacedText(
            left: 'Total',
            right: record.totalPrice().currency(),
            styleBuilder: (l, r) => (l, context.text.large),
          ),
          SpacedText(
            left: 'Due',
            right: record.due.currency(),
            styleBuilder: (l, r) {
              return (l, r.textColor(record.hasDue ? context.colors.destructive : null));
            },
          ),
          // record have due but parti have balance (-parti.due) and can be used to clear due [when sale]
          //b: -20, d: 10 = -10 final
          if (record.hasDue && record.partiHasBalance && type.isSale)
            ShadCard(
              border: Border.all(color: context.colors.destructive),
              leading: Icon(LuIcons.triangleAlert, color: context.colors.destructive),
              childPadding: Pads.sm('l'),
              rowCrossAxisAlignment: CrossAxisAlignment.center,
              child: Text('The due amount will be deducted from balance', style: context.text.muted.error(context)),
            ),
          // record have due and parti also have due (parti.due) which can be used to clear due [when purchase]
          //b: 20, d: (-)10 = 10 final
          if (record.hasDue && record.partiHasDue)
            ShadCard(
              border: Border.all(color: context.colors.destructive),
              leading: Icon(LuIcons.triangleAlert, color: context.colors.destructive),
              childPadding: Pads.sm('l'),
              rowCrossAxisAlignment: CrossAxisAlignment.center,
              child: Text(
                'The due amount will be deducted from parti\'s due',
                style: context.text.muted.error(context),
              ),
            ),
          if (record.hasBalance && !record.isWalkIn)
            ShadCard(
              border: Border.all(color: context.colors.destructive),
              leading: Icon(LuIcons.triangleAlert, color: context.colors.destructive),
              childPadding: Pads.sm('l'),
              rowCrossAxisAlignment: CrossAxisAlignment.center,
              child: Text(
                type.isSale
                    ? 'The due amount ${record.due.abs().currency()} will be added as balance'
                    : '${record.due.abs().currency()} will be added to parti\'s due',
                style: context.text.muted.error(context),
              ),
            ),
          const Gap(Insets.xs),
          SubmitButton(
            width: double.infinity,
            height: 50,
            onPressed: (l) async {
              l.truthy();
              await onSubmit();
              l.falsey();
            },
            child: Text(type.name.up, style: context.text.large.textColor(context.colors.primaryForeground)),
          ),
        ],
      ),
    );
  }
}

class _DiscountTypePopOver extends HookConsumerWidget {
  const _DiscountTypePopOver({required this.type, required this.onTypeChange});

  final DiscountType type;
  final Function(DiscountType type) onTypeChange;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final popCtrl = useMemoized(ShadPopoverController.new);

    return ShadPopover(
      controller: popCtrl,
      anchor: const ShadAnchorAuto(targetAnchor: Alignment.topRight, followerAnchor: Alignment.topCenter),
      padding: Pads.zero,
      popover: (context) {
        return SizedBox(
          width: 150,
          height: 100,
          child: IntrinsicWidth(
            child: SeparatedColumn(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              separatorBuilder: () => const ShadSeparator.horizontal(margin: Pads.zero),
              children: [
                for (final t in DiscountType.values)
                  ShadButton.ghost(
                    mainAxisAlignment: MainAxisAlignment.start,
                    child: Text(t.name.up),
                    onPressed: () {
                      popCtrl.hide();
                      onTypeChange(t);
                    },
                  ),
              ],
            ),
          ),
        );
      },
      child: ShadButton.ghost(
        trailing: const Icon(LuIcons.chevronDown),
        padding: Pads.sm('lr'),
        size: ShadButtonSize.sm,
        height: 32,
        onPressed: () => popCtrl.toggle(),
        child: Text(type.name.up),
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({
    required this.detail,
    required this.index,
    required this.onChange,
    required this.onProductRemove,
    required this.type,
  });

  final InventoryDetails detail;
  final int index;
  final Function(num price, int qty) onChange;

  final Function(String pId) onProductRemove;
  final RecordType type;

  @override
  Widget build(BuildContext context) {
    final isSale = type == RecordType.sale;
    final InventoryDetails(:product, :stock, :quantity, :price) = detail;

    final availableQty = stock.quantity - quantity;

    final qty = isSale ? quantity : stock.quantity;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      spacing: Insets.sm,
      children: [
        Text('${index + 1}.'),
        Expanded(
          child: Row(
            spacing: Insets.sm,
            children: [
              HostedImage.square(product.getPhoto, radius: Corners.sm, dimension: 60),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name),
                    if (product.manufacturer != null)
                      Text('${product.manufacturer}', style: context.text.muted.size(12).textHeight(1)),
                    const Gap(Insets.xs),
                    Text('SKU: ${product.sku}', style: context.text.muted.size(12).textHeight(1)),
                  ],
                ),
              ),
            ],
          ),
        ),
        Flexible(
          child: Column(
            spacing: Insets.xs,
            children: [
              ShadBadge.secondary(child: Text('${stock.warehouse?.name}')),
              if (isSale)
                Text(
                  '$availableQty${product.unitName}',
                  style: context.text.muted.textColor(availableQty > 0 ? null : context.colors.destructive),
                ),
            ],
          ),
        ),

        Expanded(
          child: Row(
            spacing: Insets.sm,
            children: [
              ShadIconButton.outline(
                icon: const Icon(LuIcons.minus),
                height: 30,
                width: 30,
                onPressed: () {
                  if (qty == 1) return;
                  onChange(price, qty - 1);
                },
              ),
              Text('$qty'),
              ShadIconButton.outline(
                icon: const Icon(LuIcons.plus),
                height: 30,
                width: 30,
                onPressed: () {
                  if (availableQty == 0 && isSale) return;
                  onChange(price, qty + 1);
                },
              ),
            ],
          ),
        ),

        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SpacedText(
                left: isSale ? 'Sale' : 'Purchase',
                right: (price).currency(),
                style: context.text.muted,
                crossAxisAlignment: CrossAxisAlignment.center,
                styleBuilder: (l, r) => (l, context.text.small),
                spaced: false,
              ),
              SpacedText(
                left: 'Total',
                right: detail.totalPrice().currency(),
                style: context.text.muted,
                crossAxisAlignment: CrossAxisAlignment.center,
                styleBuilder: (l, r) => (l, context.text.small),
                spaced: false,
              ),
            ],
          ),
        ),
        Row(
          children: [
            if (type.isSale)
              ShadIconButton(
                icon: const Icon(LuIcons.pen, size: 15),
                height: 30,
                width: 30,
                onPressed: () async {
                  final result = await showShadDialog<(num, int)>(
                    context: context,
                    builder: (context) => _ChangePriceDialog(detail, type),
                  );
                  if (result == null) return;
                  onChange(result.$1, result.$2);
                },
              ),
            ShadIconButton.destructive(
              icon: const Icon(LuIcons.x),
              onPressed: () => onProductRemove(product.id),
              height: 30,
              width: 30,
            ),
          ],
        ),
      ],
    );
  }
}

class _AccountSelect extends HookConsumerWidget {
  const _AccountSelect({required this.onAccountSelect, required this.type});

  final Function(PaymentAccount? acc) onAccountSelect;
  final RecordType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accList = ref.watch(paymentAccountsCtrlProvider());
    final config = ref.watch(configCtrlProvider);

    return accList.when(
      loading: () => Padding(padding: Pads.sm('lrt'), child: const ShadCard(width: 300, child: Loading())),
      error: (e, s) => ErrorView(e, s, prov: paymentAccountsCtrlProvider),
      data: (accounts) {
        return ShadSelectField<PaymentAccount>(
          label: 'Account',
          minWidth: 300,
          hintText: 'Select a payment account',
          initialValue: config.defaultAccount,
          optionBuilder: (context, acc, _) {
            return ShadOption<PaymentAccount>(
              value: acc,
              child: Row(
                children: [
                  Text(acc.name),
                  Text(
                    ' (${acc.amount.currency()})',
                    style: context.text.muted.textColor(acc.amount <= 0 ? context.colors.destructive : null),
                  ),
                ],
              ),
            );
          },
          options: accounts,
          selectedBuilder: (_, v) {
            return Row(
              children: [
                Text(v.name),
                Text(
                  ' (${v.amount.currency()})',
                  style: context.text.muted.textColor(v.amount <= 0 ? context.colors.destructive : null),
                ),
              ],
            );
          },
          onChanged: onAccountSelect,
          anchor: const ShadAnchorAuto(targetAnchor: Alignment.topCenter, followerAnchor: Alignment.topCenter),
        );
      },
    );
  }
}

class _PartiSection extends HookConsumerWidget {
  const _PartiSection({required this.onSelect, required this.record});

  final Function(Parti? parti, WalkIn? walkIn) onSelect;
  final InventoryRecordState record;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final type = record.type;
    final partiList = ref.watch(partiesCtrlProvider(null));

    final search = useState('');
    final selectCtrl = useMemoized(ShadSelectController<Parti>.new);

    final parti = record.getParti;

    return partiList.when(
      loading: () => Padding(padding: Pads.sm('lrt'), child: const ShadCard(width: 300, child: Loading())),
      error: (e, s) => ErrorView(e, s, prov: productsCtrlProvider),
      data: (parties) {
        final filtered = parties.where((e) => e.name.low.contains(search.value.low)).toList();
        return Padding(
          padding: Pads.sm('lrt'),
          child: ShadInputDecorator(
            label: const Text('Parti').required(),
            child: Wrap(
              spacing: Insets.sm,
              runSpacing: Insets.sm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ShadSelect<Parti>.withSearch(
                  controller: selectCtrl,
                  maxWidth: 400,
                  minWidth: 300,
                  placeholder: const Text('Select a parti'),
                  itemCount: filtered.length,
                  options: [
                    ShadOption(value: Parti.fromWalkIn(const WalkIn()), child: const Text('Walk-in customer')),
                    if (filtered.isEmpty) Padding(padding: Pads.med('tb'), child: const Text('No Parties found')),
                    ...filtered.map((house) {
                      return ShadOption(value: house, child: Text(house.name));
                    }),
                  ],
                  onChanged: (v) => onSelect(v, null),
                  selectedOptionBuilder: (_, v) => Text(v.name),
                  onSearchChanged: search.set,
                ),
                ShadIconButton.outline(
                  height: 38,
                  icon: const Icon(LuIcons.plus),
                  onPressed: () async {
                    await PartiesView.showAddDialog(context, type.isSale);
                  },
                ),
                if (parti != null)
                  Padding(
                    padding: Pads.sm(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: Insets.sm,
                      children: [
                        DecoContainer(
                          color: context.colors.border,
                          borderRadius: Corners.sm,
                          child: HostedImage.square(parti.getPhoto, radius: Corners.sm, dimension: 60),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (parti.isWalkIn)
                              const ShadBadge.secondary(child: Text('Walk-In'))
                            else ...[
                              Text(parti.name),
                              if (parti.due != 0)
                                Text.rich(
                                  TextSpan(
                                    text: '${parti.hasDue() ? 'Due' : 'Balance'}: ${parti.due.currency()}',
                                    children: [
                                      if (record.dueBalance > 0)
                                        TextSpan(
                                          text: ' (-${record.dueBalance.currency()})',
                                          style: context.text.p.size(12).textColor(Colors.green),
                                        ),
                                    ],
                                  ),
                                  style: context.text.p.size(12),
                                ),
                              Text(parti.phone, style: context.text.muted.size(12)),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ProductsPanel extends HookConsumerWidget {
  const ProductsPanel({super.key, required this.onProductSelect, required this.type, required this.userHouse});

  final Function(Product product, Stock? stock, WareHouse? warehouseId) onProductSelect;
  final RecordType type;
  final WareHouse? userHouse;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productList = ref.watch(productsCtrlProvider);
    final viewingWh = ref.watch(viewingWHProvider);
    final productCtrl = useCallback(() => ref.read(productsCtrlProvider.notifier));
    final search = useTextEditingController();

    return productList.when(
      loading: () => const Loading(),
      error: (e, s) => ErrorView(e, s, prov: productsCtrlProvider),
      data: (products) {
        final hId = (viewingWh == null) ? null : viewingWh.id;
        return IntrinsicWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: Pads.sm('lrt'),
                child: ShadTextField(
                  controller: search,
                  hintText: 'Search',
                  onChanged: (v) => productCtrl().search(v ?? ''),
                  showClearButton: true,
                ),
              ),

              const ShadSeparator.horizontal(),
              Expanded(
                child: GridView.builder(
                  padding: Pads.med('blr'),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 150,
                    mainAxisSpacing: Insets.sm,
                    crossAxisSpacing: Insets.sm,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final qty = product.quantityByHouse(hId);
                    return HoverBuilder(
                      child: ShadCard(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            DecoContainer(
                              color: context.colors.border,
                              borderRadius: Corners.sm,
                              alignment: Alignment.center,
                              child: HostedImage.square(product.getPhoto, radius: Corners.sm),
                            ),
                            Positioned(
                              bottom: 0,
                              left: -1,
                              right: -1,
                              child: DecoContainer(
                                color: context.colors.border.op8,
                                alignment: Alignment.center,
                                child: Text(product.name, maxLines: 3),
                              ),
                            ),
                            Positioned(
                              top: 3,
                              right: 3,
                              child: ShadBadge.raw(
                                variant:
                                    product.quantity <= 0 ? ShadBadgeVariant.destructive : ShadBadgeVariant.secondary,
                                child: Text('$qty${product.unitName}'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      builder: (hovering, child) {
                        return GestureDetector(
                          onTap: () async {
                            if (type.isSale) {
                              onProductSelect(product, null, viewingWh);
                            } else {
                              final res = await showShadDialog<Stock>(
                                barrierDismissible: false,
                                context: context,
                                builder: (context) => const _AddStockDialog(),
                              );
                              onProductSelect(product, res, null);
                            }
                          },
                          child: Stack(
                            children: [
                              child,
                              Positioned.fill(
                                child: DecoContainer.animated(
                                  duration: 250.ms,
                                  color: hovering ? context.colors.border.op7 : Colors.transparent,
                                  alignment: Alignment.center,
                                  borderRadius: Corners.med,
                                  child:
                                      hovering
                                          ? DecoContainer(
                                            color: context.colors.primary.op9,
                                            borderRadius: Corners.circle,
                                            padding: Pads.sm(),
                                            child: Icon(LuIcons.plus, color: context.colors.primaryForeground),
                                          )
                                          : null,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AddStockDialog extends HookConsumerWidget {
  const _AddStockDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final warehouseList = ref.watch(warehouseCtrlProvider);
    final searchWarehouse = useState('');

    final stock = useState<Stock>(Stock.empty(ID.unique()));

    return ShadDialog(
      title: const Text('Stock'),
      description: const Text('Add stock details'),

      actions: [
        ShadButton.destructive(onPressed: () => context.nPop(), child: const Text('Cancel')),
        ShadButton(
          onPressed: () {
            context.nPop(stock.value);
          },
          child: const Text('Add'),
        ),
      ],
      child: Container(
        padding: Pads.padding(v: Insets.med),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Insets.sm,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ShadTextField(
                    name: 'purchase_price',
                    label: 'Purchase Price',
                    hintText: 'Enter purchase price',
                    isRequired: true,
                    numeric: true,
                    onChanged: (value) {
                      stock.value = stock.value.copyWith(purchasePrice: Parser.toNum(value));
                    },
                  ),
                ),
                Expanded(
                  child: ShadTextField(
                    name: 'sales_price',
                    label: 'Sales Price',
                    hintText: 'Enter sale price',
                    isRequired: true,
                    numeric: true,
                    onChanged: (value) {
                      stock.value = stock.value.copyWith(salesPrice: Parser.toNum(value));
                    },
                  ),
                ),
              ],
            ),

            Row(
              children: [
                Expanded(
                  child: ShadTextField(
                    name: 'quantity',
                    label: 'Quantity',
                    hintText: 'Enter Stock quantity',
                    isRequired: true,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) {
                      stock.value = stock.value.copyWith(quantity: Parser.toInt(value));
                    },
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: ShadInputDecorator(
                    label: const Text('Choose warehouse').required(),
                    child: warehouseList.maybeWhen(
                      orElse: () => ShadCard(padding: kDefInputPadding, child: const Loading()),
                      data: (warehouses) {
                        final filtered = warehouses.where((e) => e.name.low.contains(searchWarehouse.value.low));
                        return LimitedWidthBox(
                          child: ShadSelect<WareHouse>.withSearch(
                            placeholder: const Text('Warehouse'),
                            options: [
                              if (filtered.isEmpty)
                                Padding(padding: Pads.padding(v: 24), child: const Text('No warehouses found')),
                              ...filtered.map((house) {
                                return ShadOption(value: house, child: Text(house.name));
                              }),
                            ],
                            selectedOptionBuilder: (context, v) => Text(v.name),
                            onSearchChanged: searchWarehouse.set,
                            allowDeselection: true,
                            onChanged: (value) {
                              stock.value = stock.value.copyWith(warehouse: () => value);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChangePriceDialog extends HookConsumerWidget {
  const _ChangePriceDialog(this.details, this.type);

  final InventoryDetails details;
  final RecordType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final price = useState<num>(details.price);
    final qty = useState(details.quantity);
    return ShadDialog(
      title: const Text('Adjust price'),
      description: const Text('Adjust stock price'),
      actions: [
        ShadButton.destructive(onPressed: () => context.nPop(), child: const Text('Cancel')),
        ShadButton(
          onPressed: () {
            if (price.value <= 0) return Toast.showErr(context, 'Price must be greater than zero');
            if (qty.value <= 0) return Toast.showErr(context, 'Quantity must be greater than zero');
            if (qty.value > details.stock.quantity && type.isSale) {
              return Toast.showErr(context, 'Quantity exceeds stock quantity');
            }
            context.nPop((price.value, qty.value));
          },
          child: const Text('Submit'),
        ),
      ],
      child: Container(
        padding: Pads.padding(v: Insets.med),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Insets.sm,
          children: [
            Row(
              children: [
                Expanded(
                  child: ShadTextField(
                    name: 'price',
                    initialValue: details.price.toString(),
                    label: 'Price',
                    hintText: 'Enter price',
                    isRequired: true,
                    numeric: true,
                    onChanged: (v) => price.value = Parser.toNum(v) ?? 0,
                  ),
                ),
                Expanded(
                  child: ShadTextField(
                    name: 'quantity',
                    label: 'Quantity',
                    initialValue: details.quantity.toString(),
                    hintText: 'Enter quantity',
                    isRequired: true,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (v) => qty.value = Parser.toInt(v) ?? 0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
