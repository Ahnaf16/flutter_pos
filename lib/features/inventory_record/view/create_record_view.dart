import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:pos/_widgets/hover_builder.dart';
import 'package:pos/features/inventory_record/controller/record_editing_ctrl.dart';
import 'package:pos/features/parties/controller/parties_ctrl.dart';
import 'package:pos/features/parties/view/parties_view.dart';
import 'package:pos/features/payment_accounts/controller/payment_accounts_ctrl.dart';
import 'package:pos/features/products/controller/products_ctrl.dart';
import 'package:pos/main.export.dart';

class CreateRecordView extends HookConsumerWidget {
  const CreateRecordView({super.key, required this.type});
  final RecordType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final record = ref.watch(recordEditingCtrlProvider);
    final recordCtrl = useCallback(() => ref.read(recordEditingCtrlProvider.notifier));

    final isSale = type == RecordType.sale;

    return BaseBody(
      title: type.name.up,

      padding: context.layout.pagePadding.copyWith(top: 5, bottom: 15),
      body: ShadCard(
        padding: Pads.zero,
        child: ShadResizablePanelGroup(
          showHandle: true,
          children: [
            ShadResizablePanel(
              id: 0,
              defaultSize: .8,
              child: Column(
                spacing: Insets.sm,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //! Parti
                  _PartiSection(onPartiSelect: recordCtrl().changeParti, parti: record.parti, type: type),
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
                                  onQtyChange: (q) => recordCtrl().changeQuantity(detail.product.id, (_) => q),
                                  onProductRemove: (pId) => recordCtrl().removeProduct(pId),
                                );
                              },
                            ),
                          ),
                        ),

                        //! calculations
                        ShadResizablePanel(
                          id: 3,
                          defaultSize: 0.3,
                          minSize: 0.1,
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
                                    type: type,
                                    onTypeChange: recordCtrl().changeDiscountType,
                                    onAccountSelect: recordCtrl().changeAccount,
                                    onInputChange: recordCtrl().setInputsFromMap,
                                  ),
                                ),
                                const SizedBox(height: 200, child: ShadSeparator.vertical()),

                                //! summary
                                Expanded(
                                  child: _Summary(
                                    record: record,
                                    type: type,
                                    onSubmit: () async => recordCtrl().submitSale(),
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
              defaultSize: .3,
              minSize: .2,
              maxSize: .4,
              child: _ProductsPanel(onProductSelect: (p) => recordCtrl().addProduct(p)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Inputs extends HookConsumerWidget {
  const _Inputs({
    required this.onTypeChange,
    required this.record,
    required this.type,
    required this.onAccountSelect,
    required this.onInputChange,
  });

  final InventoryRecordState record;
  final RecordType type;
  final Function(DiscountType type) onTypeChange;
  final Function(PaymentAccount? acc) onAccountSelect;
  final Function(QMap formData) onInputChange;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    return FormBuilder(
      key: formKey,
      onChanged: () {
        final state = formKey.currentState!;
        onInputChange(state.instantValue);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Insets.sm,
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: ShadField(
                  name: 'amount',
                  hintText: 'Amount',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.allow(decimalRegExp)],
                ),
              ),
              Expanded(
                child: ShadField(
                  name: 'vat',
                  hintText: 'Vat',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.allow(decimalRegExp)],
                ),
              ),
            ],
          ),

          Row(
            children: [
              Expanded(
                flex: 4,
                child: ShadField(
                  name: 'discount',
                  hintText: 'Discount',
                  padding: kDefInputPadding.copyWith(bottom: 0, top: 0, right: 5),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.allow(decimalRegExp)],
                  trailing: _DiscountTypePopOver(onTypeChange: onTypeChange, type: record.discountType),
                ),
              ),
              Expanded(
                flex: 3,
                child: ShadField(
                  name: 'shipping',
                  hintText: 'Shipping',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.allow(decimalRegExp)],
                ),
              ),
            ],
          ),
          _AccountSelect(onAccountSelect: onAccountSelect, type: type),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.record, required this.type, required this.onSubmit});

  final InventoryRecordState record;
  final RecordType type;
  final FVoid Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: Insets.sm,
      children: [
        SpacedText(left: 'Subtotal', right: record.subtotalSale().currency(), styleBuilder: (l, r) => (l, r.bold)),
        SpacedText(
          left: 'Total',
          right: record.totalPriceSale().currency(),
          styleBuilder: (l, r) => (l, context.text.large),
        ),
        SpacedText(
          left: 'Due',
          right: record.due.currency(),
          styleBuilder: (l, r) {
            return (l, r.textColor(record.hasDue ? context.colors.destructive : null));
          },
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
    required this.onQtyChange,
    required this.onProductRemove,
    required this.type,
  });

  final InventoryDetails detail;
  final int index;
  final Function(int qty) onQtyChange;
  final Function(String pId) onProductRemove;
  final RecordType type;

  @override
  Widget build(BuildContext context) {
    final isSale = type == RecordType.sale;
    final InventoryDetails(:product, :stock, :quantity) = detail;

    final availableQty = stock.quantity - quantity;
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
                  if (quantity == 1) return;
                  onQtyChange(quantity - 1);
                },
              ),
              Text('$quantity'),
              ShadIconButton.outline(
                icon: const Icon(LuIcons.plus),
                height: 30,
                width: 30,
                onPressed: () {
                  if (availableQty == 0) return;
                  onQtyChange(quantity + 1);
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
                left: isSale ? 'Sale price' : 'Purchase price',
                right: (isSale ? stock.salesPrice : stock.purchasePrice).currency(),
                style: context.text.muted,
                crossAxisAlignment: CrossAxisAlignment.center,
                styleBuilder: (l, r) => (l, context.text.small),
              ),
              SpacedText(
                left: 'Total amount',
                right: detail.totalPriceByType(type).currency(),
                style: context.text.muted,
                crossAxisAlignment: CrossAxisAlignment.center,
                styleBuilder: (l, r) => (l, context.text.small),
              ),
            ],
          ),
        ),
        ShadIconButton.destructive(
          icon: const Icon(LuIcons.x),
          onPressed: () => onProductRemove(product.id),
          height: 30,
          width: 30,
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
    final accList = ref.watch(paymentAccountsCtrlProvider);

    return accList.when(
      loading: () => Padding(padding: Pads.sm('lrt'), child: const ShadCard(width: 300, child: Loading())),
      error: (e, s) => ErrorView(e, s, prov: productsCtrlProvider),
      data: (accounts) {
        if (type == RecordType.purchase) accounts = accounts.where((e) => e.amount > 0).toList();
        return ShadInputDecorator(
          label: const Text('Account').required(),
          child: ShadSelect<PaymentAccount>(
            maxWidth: 300,
            minWidth: 300,
            placeholder: const Text('Select a payment account'),
            itemCount: accounts.length,
            options: [
              for (final acc in accounts)
                ShadOption<PaymentAccount>(
                  value: acc,
                  child: Row(
                    children: [
                      Text(acc.name),
                      Text(
                        ' (${acc.amount.currency()})',
                        style: context.text.muted.textColor(acc.amount == 0 ? context.colors.destructive : null),
                      ),
                    ],
                  ),
                ),
            ],
            selectedOptionBuilder: (_, v) {
              return Row(
                children: [
                  Text(v.name),
                  Text(
                    ' (${v.amount.currency()})',
                    style: context.text.muted.textColor(v.amount == 0 ? context.colors.destructive : null),
                  ),
                ],
              );
            },
            onChanged: onAccountSelect,
            anchor: const ShadAnchorAuto(targetAnchor: Alignment.topRight, followerAnchor: Alignment.topCenter),
          ),
        );
      },
    );
  }
}

class _PartiSection extends HookConsumerWidget {
  const _PartiSection({required this.onPartiSelect, required this.parti, required this.type});

  final Function(Parti? parti) onPartiSelect;
  final Parti? parti;
  final RecordType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partiList = ref.watch(partiesCtrlProvider(null));

    final search = useState('');

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
                  maxWidth: 400,
                  minWidth: 300,
                  placeholder: const Text('Select a parti '),
                  itemCount: filtered.length,
                  options: [
                    if (filtered.isEmpty)
                      Padding(
                        padding: Pads.med('tb'),
                        child: Column(
                          spacing: Insets.sm,
                          children: [
                            const Text('No Parties found'),
                            ShadButton.outline(
                              size: ShadButtonSize.sm,
                              padding: Pads.sm(),
                              onPressed: () => PartiesView.showAddDialog(context, type == RecordType.sale),
                              leading: const Icon(LuIcons.plus, size: 12),
                              child: const Text('Add Parti'),
                            ),
                          ],
                        ),
                      ),
                    ...filtered.map((house) {
                      return ShadOption(value: house, child: Text(house.name));
                    }),
                  ],
                  onChanged: (v) => onPartiSelect(v),
                  selectedOptionBuilder: (_, v) => Text(v.name),
                  onSearchChanged: search.set,
                ),
                ShadIconButton.outline(
                  height: 38,
                  icon: const Icon(LuIcons.plus),
                  onPressed: () async {
                    await PartiesView.showAddDialog(context, type == RecordType.sale);
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
                          child: HostedImage.square(parti!.getPhoto, radius: Corners.sm, dimension: 60),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(parti!.name),
                            Text('Due: ${parti!.due.currency()}', style: context.text.p.size(12)),
                            Text(parti!.phone, style: context.text.muted.size(12)),
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

class _ProductsPanel extends HookConsumerWidget {
  const _ProductsPanel({required this.onProductSelect});

  final Function(Product product) onProductSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productList = ref.watch(productsCtrlProvider);
    final productCtrl = useCallback(() => ref.read(productsCtrlProvider.notifier));
    final search = useTextEditingController();
    return productList.when(
      loading: () => const Loading(),
      error: (e, s) => ErrorView(e, s, prov: productsCtrlProvider),
      data: (products) {
        return Column(
          spacing: Insets.med,
          children: [
            Padding(
              padding: Pads.sm('lrt'),
              child: ShadInput(
                controller: search,
                padding: Pads.sm(),
                placeholder: const Text('Search'),
                onChanged: (v) => productCtrl().search(v),
                trailing: ShadButton.outline(
                  width: 24,
                  height: 24,
                  padding: Pads.zero,
                  leading: const Icon(LuIcons.x),
                  onPressed: () => search.clear(),
                ),
              ),
            ),
            const ShadSeparator.horizontal(margin: Pads.zero),
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
                              color: Colors.black87,
                              alignment: Alignment.center,
                              child: Text(product.name, maxLines: 3),
                            ),
                          ),
                          Positioned(
                            top: 3,
                            right: 3,
                            child: ShadBadge.raw(
                              variant:
                                  product.quantity == 0 ? ShadBadgeVariant.destructive : ShadBadgeVariant.secondary,
                              child: Text('${product.quantity}${product.unitName}'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    builder: (hovering, child) {
                      return GestureDetector(
                        onTap: () => onProductSelect(product),
                        child: Stack(
                          children: [
                            child,
                            Positioned.fill(
                              child: DecoContainer.animated(
                                duration: 250.ms,
                                color: hovering ? Colors.black54 : Colors.transparent,
                                alignment: Alignment.center,
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
        );
      },
    );
  }
}
