import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:pos/features/auth/controller/auth_ctrl.dart';
import 'package:pos/features/inventory_record/controller/record_editing_ctrl.dart';
import 'package:pos/features/inventory_record/view/local/discount_type_pop_over.dart';
import 'package:pos/features/inventory_record/view/local/products_panel.dart';
import 'package:pos/features/inventory_record/view/payment_account_select.dart';
import 'package:pos/features/parties/controller/parties_ctrl.dart';
import 'package:pos/features/parties/view/parties_view.dart';
import 'package:pos/features/products/controller/products_ctrl.dart';
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
            final state = formKey.currentState?..saveAndValidate();
            recordCtrl().setInputsFromMap(state?.instantValue ?? {});
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
                                    itemCount: record.details.length,
                                    shrinkWrap: true,
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
                                const ShadSeparator.horizontal(),
                                //! calculations
                                Row(
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

                                    //! summary
                                    Expanded(
                                      child: _Summary(
                                        record: record,
                                        onSubmit: () async {
                                          final res = await recordCtrl().submit();
                                          if (context.mounted) res.showToast(context);

                                          if (res.success) {
                                            formKey.currentState?.reset();
                                          }
                                        },
                                      ),
                                    ),
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
                  ShadResizablePanel(
                    id: 1,
                    defaultSize: .35,
                    minSize: .2,
                    maxSize: .4,
                    child: ProductsPanel(
                      type: type,
                      userHouse: user?.warehouse,
                      onProductSelect: (p, s, w) => recordCtrl().addProduct(p, newStock: s, warehouse: w),
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
                hintText: type.isSale ? 'Payment amount' : 'Paid amount',
                keyboardType: TextInputType.number,
                numeric: true,
              ),
            ),
            Expanded(
              child: ShadTextField(
                name: 'vat',
                hintText: 'Vat',
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
                hintText: 'Discount',
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
                hintText: 'Shipping',
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
          SpacedText(left: 'Subtotal', right: record.subtotal().currency(), styleBuilder: (l, r) => (l, r.bold)),
          SpacedText(
            left: 'Total',
            right: record.totalPrice().currency(),
            crossAxisAlignment: CrossAxisAlignment.center,
            styleBuilder: (l, r) => (l, context.text.large),
          ),
          SpacedText(
            left: record.hasBalance ? 'Extra' : 'Due',
            right: record.due.abs().currency(),
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

          if (record.hasBalance && !record.isWalkIn && type.isSale)
            ShadCard(
              border: Border.all(color: context.colors.destructive),
              leading: Icon(LuIcons.triangleAlert, color: context.colors.destructive),
              childPadding: Pads.sm('l'),
              rowCrossAxisAlignment: CrossAxisAlignment.center,
              child: Text('The extra amount will be added as balance', style: context.text.muted.error(context)),
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

class _PartiSection extends HookConsumerWidget {
  const _PartiSection({required this.onSelect, required this.record});

  final Function(Party? parti) onSelect;
  final InventoryRecordState record;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final type = record.type;
    final partiList = ref.watch(partiesCtrlProvider(type.isSale));

    final search = useState('');
    final selectCtrl = useMemoized(ShadSelectController<Party>.new);

    final parti = record.getParti;

    return partiList.when(
      loading: () => Padding(padding: Pads.sm('lrt'), child: const ShadCard(width: 300, child: Loading())),
      error: (e, s) => ErrorView(e, s, prov: productsCtrlProvider),
      data: (parties) {
        final filtered = parties.where((e) => e.name.low.contains(search.value.low)).toList();
        return Padding(
          padding: Pads.sm('lrt'),
          child: ShadInputDecorator(
            label: Text(type.isSale ? 'Customer' : 'Supplier').required(),
            child: Wrap(
              spacing: Insets.sm,
              runSpacing: Insets.sm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ShadSelect<Party>.withSearch(
                  controller: selectCtrl,
                  maxWidth: 400,
                  minWidth: 300,
                  placeholder: Text(type.isSale ? 'Customer' : 'Supplier'),
                  itemCount: filtered.length,
                  initialValue: parti,
                  options: [
                    if (type.isSale) ShadOption(value: Party.fromWalkIn(), child: const Text('Walk-in customer')),
                    if (filtered.isEmpty) Padding(padding: Pads.med('tb'), child: const Text('No Parties found')),
                    ...filtered.map((house) {
                      return ShadOption(value: house, child: Text(house.name));
                    }),
                  ],
                  onChanged: (v) => onSelect(v),
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
                                  TextSpan(text: '${parti.hasDue() ? 'Due' : 'Balance'}: ${parti.due.currency()}'),
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
