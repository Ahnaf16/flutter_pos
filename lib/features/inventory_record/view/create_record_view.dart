import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:pos/features/auth/controller/auth_ctrl.dart';
import 'package:pos/features/home/controller/home_ctrl.dart';
import 'package:pos/features/inventory_record/controller/record_editing_ctrl.dart';
import 'package:pos/features/inventory_record/view/local/discount_type_pop_over.dart';
import 'package:pos/features/inventory_record/view/local/inv_invoice_widget.dart';
import 'package:pos/features/inventory_record/view/local/products_panel.dart';
import 'package:pos/features/inventory_record/view/payment_account_select.dart';
import 'package:pos/features/inventory_record/view/stock_selection_dialog.dart';
import 'package:pos/features/parties/controller/parties_ctrl.dart';
import 'package:pos/features/parties/view/parties_view.dart';
import 'package:pos/features/products/controller/products_ctrl.dart';
import 'package:pos/features/settings/controller/settings_ctrl.dart';
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
    final vWh = ref.watch(viewingWHProvider);
    // final isSale = type == RecordType.sale;

    return BaseBody(
      title: type.name.titleCase,
      body: FormBuilder(
        key: formKey,
        onChanged: () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final state = formKey.currentState;
            recordCtrl().setInputsFromMap(state?.instantValue ?? {});
          });
        },
        child: user.when(
          loading: () => const Loading(),
          error: (e, s) => ErrorView(e, s, prov: currentUserProvider),
          data: (user) {
            final isMobile = context.layout.isMobile;
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
                          onSelect: (p) {
                            recordCtrl().changeParti(p);
                            formKey.currentState?.fields['due_balance']?.reset();
                          },
                        ),
                        const ShadSeparator.horizontal(margin: Pads.zero),
                        Expanded(
                          child: Padding(
                            padding: Pads.sm(),
                            child: Column(
                              spacing: Insets.sm,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //! selected products
                                Expanded(
                                  child: ListView.separated(
                                    padding: Pads.med('blr'),
                                    itemCount: record.details.length + (isMobile ? 1 : 0),
                                    shrinkWrap: true,
                                    separatorBuilder: (_, _) => const ShadSeparator.horizontal(),
                                    itemBuilder: (BuildContext context, int index) {
                                      final isLast = index == record.details.length && isMobile;
                                      if (isLast) {
                                        return ShadButton.secondary(
                                          leading: const Icon(LuIcons.plus),
                                          child: const SelectionContainer.disabled(child: Text('Add Product')),
                                          onPressed: () {
                                            showShadSheet(
                                              context: context,
                                              side: ShadSheetSide.right,
                                              useRootNavigator: true,
                                              builder: (context) => ShadSheet(
                                                constraints: BoxConstraints(maxWidth: context.width * .8),
                                                padding: Pads.xl('tb'),
                                                title: Row(
                                                  spacing: Insets.med,
                                                  children: [
                                                    ShadIconButton.ghost(
                                                      icon: const Icon(LuIcons.x),
                                                      onPressed: () => context.nPop(),
                                                    ),
                                                    const Text('Add Product'),
                                                  ],
                                                ),
                                                scrollable: false,
                                                child: ProductsPanel(
                                                  type: type,
                                                  userHouse: user?.warehouse,
                                                  onProductSelect: (p, s, w) {
                                                    recordCtrl().addProduct(p, stock: s, warehouse: w);
                                                  },
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      }
                                      final detail = record.details[index];
                                      return _ProductTile(
                                        detail: detail,
                                        index: index,
                                        type: type,
                                        onChange: (p, q) {
                                          recordCtrl().changeQuantity(detail, (_) => q);
                                          recordCtrl().updatePrice(detail, p);
                                        },
                                        onStockChange: (stock) => recordCtrl().updateStock(detail.id, stock),
                                        onQtyEnd: () async {
                                          final allStockIds = record.details.map((e) => e.stock.id).toList();

                                          final stocks = detail.product
                                              .sortByNewest(vWh.viewing?.id)
                                              .where((e) => e.quantity > 0 && !allStockIds.contains(e.id))
                                              .toList();

                                          if (stocks.isEmpty) {
                                            return Toast.showErr(context, 'No stock available');
                                          }
                                          final selected = await showShadDialog(
                                            context: context,
                                            builder: (context) {
                                              return StockSelectionDialog(
                                                product: detail.product,
                                                stocks: stocks,
                                                detailIds: allStockIds,
                                              );
                                            },
                                          );
                                          if (selected case final Stock s) {
                                            recordCtrl().addInvDetails(detail.product, s);
                                          }
                                        },
                                        onProductRemove: (pId) => recordCtrl().removeProduct(pId, detail.stock.id),
                                      );
                                    },
                                  ),
                                ),
                                const ShadSeparator.horizontal(),
                                //! calculations
                                Flex(
                                  direction: isMobile ? Axis.vertical : Axis.horizontal,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: Insets.sm,
                                  children: [
                                    //! inputs
                                    _Inputs(
                                      record: record,
                                      onTypeChange: recordCtrl().changeDiscountType,
                                      onAccountSelect: recordCtrl().changeAccount,
                                    ).conditionalExpanded(!isMobile, 2),

                                    //! summary
                                    _Summary(
                                      record: record,
                                      onSubmit: () async {
                                        if (formKey.currentState?.saveAndValidate() == false) return;

                                        final (res, inv) = await recordCtrl().submit();
                                        if (context.mounted) res.showToast(context);

                                        if (res.success) {
                                          formKey.currentState?.reset();

                                          final config = await ref.read(configCtrlAsyncProvider.future);
                                          if (!context.mounted) return;

                                          if (type.isPurchase) {
                                            RPaths.purchases.goNamed(context);
                                          } else {
                                            RPaths.sales.goNamed(context);
                                          }

                                          if (inv != null) {
                                            await showShadDialog(
                                              context: context,
                                              builder: (context) => InvInvoiceWidget(rec: inv, config: config),
                                            );
                                          }
                                        }
                                      },
                                    ).conditionalExpanded(!isMobile),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  //! Products list
                  if (!isMobile)
                    ShadResizablePanel(
                      id: 1,
                      defaultSize: .35,
                      minSize: .2,
                      maxSize: .4,
                      child: ProductsPanel(
                        type: type,
                        userHouse: user?.warehouse,
                        onProductSelect: (p, s, w) async {
                          recordCtrl().addProduct(p, stock: s, warehouse: w);
                        },
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
                label: type.isSale ? 'Payment amount' : 'Paid amount',
                hintText: 'eg: 0.00',
                keyboardType: TextInputType.number,
                numeric: true,
              ),
            ),
            Expanded(
              child: ShadTextField(
                name: 'vat',
                hintText: 'eg: 0.00',
                label: 'Vat',
                keyboardType: TextInputType.number,
                numeric: true,
              ),
            ),
          ],
        ),

        Row(
          children: [
            Expanded(
              flex: 4,
              child: ShadTextField(
                name: 'discount',
                hintText: 'eg: 0.00',
                label: 'Discount',
                padding: kDefInputPadding.copyWith(bottom: 0, top: 0, right: 5),
                keyboardType: TextInputType.number,
                numeric: true,
                trailing: DiscountTypePopOver(onTypeChange: onTypeChange, type: record.discountType),
              ),
            ),
            Expanded(
              flex: 3,
              child: ShadTextField(
                name: 'shipping',
                hintText: 'eg: 0.00',
                label: 'Shipping',
                keyboardType: TextInputType.number,
                numeric: true,
              ),
            ),
          ],
        ),

        PaymentAccountSelect(onAccountSelect: onAccountSelect, type: type),
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
          Row(
            children: [
              Expanded(
                child: Column(
                  spacing: Insets.sm,
                  children: [
                    SpacedText(
                      spaced: true,
                      left: 'Subtotal',
                      right: record.subtotal().currency(),
                      styleBuilder: (l, r) => (l, r.bold),
                    ),
                    SpacedText(
                      spaced: true,
                      left: 'Total',
                      right: record.totalPrice().currency(),
                      crossAxisAlignment: CrossAxisAlignment.center,
                      styleBuilder: (l, r) => (l, context.text.large),
                    ),
                    SpacedText(
                      spaced: true,
                      left: record.hasExtra ? 'Extra' : 'Due',
                      right: record.due.abs().currency(),
                      styleBuilder: (l, r) {
                        return (l, r.textColor(record.hasDue ? context.colors.destructive : null));
                      },
                    ),
                  ],
                ),
              ),
              if (context.layout.isMobile)
                SubmitButton(
                  height: 50,
                  width: 140,
                  onPressed: (l) async {
                    l.truthy();
                    await onSubmit();
                    l.falsey();
                  },
                  child: Text(
                    type.name.up,
                    style: context.text.large.textColor(context.colors.primaryForeground),
                  ),
                ),
            ],
          ),

          // record have due but parti have balance (-parti.due) and can be used to clear due [when sale]
          //b: -20, d: 10 = -10 final
          if (record.hasDue && record.partiHasBalance && type.isSale)
            ShadCard(
              border: Border.all(color: context.colors.destructive),
              leading: Icon(LuIcons.triangleAlert, color: context.colors.destructive),
              childPadding: Pads.sm('l'),
              rowCrossAxisAlignment: CrossAxisAlignment.center,
              child: Text(
                'The due amount will be deducted from balance',
                style: context.text.muted.error(context),
              ),
            ),

          if (record.hasExtra && !record.isWalkIn && type.isSale)
            ShadCard(
              border: Border.all(color: context.colors.destructive),
              leading: Icon(LuIcons.triangleAlert, color: context.colors.destructive),
              childPadding: Pads.sm('l'),
              rowCrossAxisAlignment: CrossAxisAlignment.center,
              child: Text('The extra amount will be added as balance', style: context.text.muted.error(context)),
            ),
          if (!context.layout.isMobile) const Gap(Insets.xs),
          if (!context.layout.isMobile)
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

class _ProductTile extends StatelessWidget {
  const _ProductTile({
    required this.detail,
    required this.index,
    required this.onChange,
    required this.onProductRemove,
    required this.type,
    required this.onQtyEnd,
    required this.onStockChange,
  });

  final InventoryDetails detail;
  final int index;
  final Function(num price, int qty) onChange;
  final void Function() onQtyEnd;
  final Function(String pId) onProductRemove;
  final Function(Stock? stock) onStockChange;
  final RecordType type;

  @override
  Widget build(BuildContext context) {
    final isSale = type == RecordType.sale;
    final InventoryDetails(:product, :stock, :quantity, :price) = detail;

    final availableQty = stock.quantity - quantity;

    final qty = isSale ? quantity : stock.quantity;

    if (context.layout.isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Insets.sm,
            children: [
              Text('${index + 1}.'),
              HostedImage.square(product.getPhoto(), radius: Corners.sm, dimension: 60),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, maxLines: 1),
                    if (product.manufacturer != null)
                      Text('${product.manufacturer}', style: context.text.muted.size(12).textHeight(1)),
                    const Gap(Insets.xs),
                    Text('SKU: ${product.sku}', style: context.text.muted.size(12).textHeight(1)),
                    const Gap(Insets.xs),
                    Row(
                      spacing: Insets.sm,
                      children: [
                        ShadBadge.secondary(child: Text('${stock.warehouse?.name}')),
                        if (isSale)
                          Text(
                            '$availableQty${product.unitName}',
                            style: context.text.muted.textColor(
                              availableQty > 0 ? null : context.colors.destructive,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  ShadIconButton(
                    icon: const Icon(LuIcons.pen, size: 15),
                    height: 30,
                    width: 30,
                    onPressed: () async {
                      if (type.isSale) {
                        final result = await showShadDialog<(num, int)>(
                          context: context,
                          builder: (context) => _ChangePriceDialog(detail, type),
                        );
                        if (result != null) onChange(result.$1, result.$2);
                      } else {
                        final st = await showShadDialog<Stock>(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) => AddStockDialog(exStock: detail.stock),
                        );

                        onStockChange(st);
                      }
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
          ),
          const Gap(Insets.med),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: SpacedText(
                  left: isSale ? 'Sale' : 'Purchase',
                  right: (price).currency(),
                  style: context.text.muted,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  styleBuilder: (l, r) => (l, context.text.small),
                ),
              ),
              Expanded(
                child: SpacedText(
                  left: 'Total',
                  right: detail.totalPrice().currency(),
                  style: context.text.muted,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  styleBuilder: (l, r) => (l, context.text.small),
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
                        if (availableQty == 0 && isSale) return onQtyEnd();
                        onChange(price, qty + 1);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      spacing: Insets.sm,
      children: [
        Text('${index + 1}.'),
        Expanded(
          child: Row(
            spacing: Insets.sm,
            children: [
              HostedImage.square(product.getPhoto(), radius: Corners.sm, dimension: 60),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SpacedText(
                left: isSale ? 'Sale' : 'Purchase',
                right: (price).currency(),
                style: context.text.muted,
                crossAxisAlignment: CrossAxisAlignment.center,
                styleBuilder: (l, r) => (l, context.text.small),
              ),
              SpacedText(
                left: 'Total',
                right: detail.totalPrice().currency(),
                style: context.text.muted,
                crossAxisAlignment: CrossAxisAlignment.center,
                styleBuilder: (l, r) => (l, context.text.small),
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
                  if (availableQty == 0 && isSale) return onQtyEnd();
                  onChange(price, qty + 1);
                },
              ),
            ],
          ),
        ),

        Row(
          children: [
            ShadIconButton(
              icon: const Icon(LuIcons.pen, size: 15),
              height: 30,
              width: 30,
              onPressed: () async {
                if (type.isSale) {
                  final result = await showShadDialog<(num, int)>(
                    context: context,
                    builder: (context) => _ChangePriceDialog(detail, type),
                  );
                  if (result != null) onChange(result.$1, result.$2);
                } else {
                  final st = await showShadDialog<Stock>(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) => AddStockDialog(exStock: detail.stock),
                  );

                  onStockChange(st);
                }
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

class _PartiSection extends HookConsumerWidget {
  const _PartiSection({required this.onSelect, required this.record});

  final Function(Party? parti) onSelect;
  final InventoryRecordState record;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final type = record.type;
    final partiList = ref.watch(partiesCtrlProvider(type.isSale));

    final parti = record.getParti;

    return partiList.when(
      loading: () => Padding(
        padding: Pads.sm('lrt'),
        child: const ShadCard(width: 300, child: Loading()),
      ),
      error: (e, s) => ErrorView(e, s, prov: productsCtrlProvider),
      data: (parties) {
        if (type.isSale) {
          parties = [Party.fromWalkIn(), ...parties];
        }
        return Padding(
          padding: Pads.sm('lrt'),
          child: ShadInputDecorator(
            child: Row(
              spacing: Insets.sm,
              children: [
                LimitedWidthBox(
                  maxWidth: context.layout.isMobile ? 300 : 400,
                  center: false,
                  child: ShadSelectField<Party>(
                    isRequired: true,
                    label: type.isSale ? 'Customer' : 'Supplier',
                    hintText: type.isSale ? 'Customer' : 'Supplier',
                    initialValue: parti,
                    options: parties,
                    optionBuilder: (_, value, _) => ShadOption(value: value, child: Text(value.name)),
                    onChanged: (v) {
                      onSelect(v);
                    },
                    selectedBuilder: (_, v) => Text(v.name),
                    searchBuilder: (v) => v.name,
                    outsideTrailing: ShadIconButton.outline(
                      height: 38,
                      icon: const Icon(LuIcons.plus),
                      onPressed: () async {
                        await PartiesView.showAddDialog(context, type.isSale);
                      },
                    ),
                  ),
                ),

                if (parti != null)
                  Padding(
                    padding: Pads.sm().copyWith(
                      top: parti.isWalkIn ? 25 : 7,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: Insets.sm,
                      children: [
                        if (!parti.isWalkIn)
                          DecoContainer(
                            color: context.colors.border,
                            borderRadius: Corners.sm,
                            child: HostedImage.square(
                              parti.getPhoto,
                              radius: Corners.sm,
                              dimension: context.layout.isMobile ? 50 : 60,
                            ),
                          ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (parti.isWalkIn)
                              const ShadBadge.secondary(child: Text('Walk-In'))
                            else ...[
                              Text(parti.name, maxLines: 1),
                              if (parti.due != 0)
                                Text.rich(
                                  TextSpan(
                                    text: '${parti.hasDue() ? 'Due' : 'Balance'}: ${parti.due.abs().currency()}',
                                  ),
                                  style: context.text.p.size(12),
                                  maxLines: 1,
                                ),
                              Text(parti.phone, style: context.text.muted.size(12), maxLines: 1),
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
        ShadButton.destructive(
          onPressed: () => context.nPop(),
          child: const SelectionContainer.disabled(child: Text('Cancel')),
        ),
        ShadButton(
          onPressed: () {
            if (price.value <= 0) return Toast.showErr(context, 'Price must be greater than zero');
            if (qty.value <= 0) return Toast.showErr(context, 'Quantity must be greater than zero');
            if (qty.value > details.stock.quantity && type.isSale) {
              return Toast.showErr(context, 'Quantity exceeds stock quantity');
            }
            context.nPop((price.value, qty.value));
          },
          child: const SelectionContainer.disabled(child: Text('Submit')),
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
