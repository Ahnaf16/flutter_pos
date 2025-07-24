import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:pos/features/home/controller/home_ctrl.dart';
import 'package:pos/features/inventory_record/view/local/no_product_select.dart';
import 'package:pos/features/inventory_record/view/local/products_panel.dart';
import 'package:pos/features/products/controller/products_ctrl.dart';
import 'package:pos/features/settings/controller/settings_ctrl.dart';
import 'package:pos/features/stockTransfer/controller/stock_transfer_ctrl.dart';
import 'package:pos/features/warehouse/controller/warehouse_ctrl.dart';
import 'package:pos/main.export.dart';

class StockTransferView extends HookConsumerWidget {
  const StockTransferView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final viewingWh = ref.watch(viewingWHProvider);
    final policy = ref.watch(configCtrlProvider.select((e) => e.stockDistPolicy));

    final warehouseList = ref.watch(warehouseCtrlProvider);

    final transferState = ref.watch(stockTransferCtrlProvider);
    final StockTransferState(:product, :from, :to, :quantity) = transferState;
    final tCtrl = useCallback(() => ref.read(stockTransferCtrlProvider.notifier));

    final selectedFrom = useState<WareHouse?>(viewingWh.my);

    useValueChanged(viewingWh, (_, _) async {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        formKey.currentState?.reset();
        tCtrl().reset();
      });
    });

    final isMobile = context.layout.isMobile;

    return BaseBody(
      title: 'Stock Transfer',
      scrollable: isMobile,
      body: FormBuilder(
        key: formKey,
        onChanged: () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final state = formKey.currentState!;
            tCtrl().setStockData(state.instantValue);
          });
        },

        child: ShadCard(
          padding: Pads.zero,
          child: ShadResizablePanelGroup(
            crossAxisAlignment: product == null ? null : CrossAxisAlignment.start,
            children: [
              ShadResizablePanel(
                id: 0,
                defaultSize: .7,
                child: SingleChildScrollView(
                  physics: isMobile ? const NeverScrollableScrollPhysics() : null,
                  child: Column(
                    mainAxisAlignment: product == null ? MainAxisAlignment.center : MainAxisAlignment.start,
                    children: [
                      if (product == null)
                        Padding(
                          padding: Pads.xl(),
                          child: NoProductSelectedView(
                            isButtonEnabled: isMobile ? true : false,
                            onTap: () {
                              _showSheet(context, viewingWh.viewing, tCtrl, formKey);
                            },
                          ),
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShadCard(
                              border: const Border(),
                              shadows: const [],
                              padding: Pads.med(),
                              childPadding: Pads.med('tb'),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Product info'),
                                  if (isMobile)
                                    ShadButton.link(
                                      leading: const Icon(LuIcons.pen),
                                      child: const SelectionContainer.disabled(child: Text('Change Product')),
                                      onPressed: () {
                                        _showSheet(context, viewingWh.viewing, tCtrl, formKey);
                                      },
                                    ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: Insets.med,
                                children: [
                                  Row(
                                    spacing: Insets.med,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      HostedImage.square(product.getPhoto(), dimension: 80, radius: Corners.med),
                                      Flexible(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          spacing: Insets.sm,
                                          children: [
                                            Row(
                                              spacing: Insets.sm,
                                              children: [
                                                Text(product.name, style: context.text.lead),
                                                if (product.manufacturer != null)
                                                  ShadBadge.outline(
                                                    child: Text(
                                                      '${product.manufacturer}',
                                                      style: context.text.muted.size(12).textHeight(1),
                                                    ),
                                                  ),
                                              ],
                                            ),

                                            Text(
                                              'SKU: ${product.sku}',
                                              style: context.text.muted.size(12).textHeight(1),
                                            ),
                                            Row(
                                              spacing: Insets.sm,
                                              children: [
                                                ShadBadge.secondary(
                                                  child: Text(
                                                    '${product.quantityByHouse(from?.id)}${product.unitName}',
                                                  ),
                                                ),
                                                ShadBadge.secondary(
                                                  child: Text('${product.stocksByHouse(from?.id).length} stocks'),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  ShadCard(
                                    child: ShadAccordion<int>(
                                      initialValue: 1,
                                      children: [
                                        ShadAccordionItem<int>(
                                          value: 1,
                                          padding: Pads.sm(),
                                          separator: const ShadSeparator.horizontal(margin: Pads.zero),
                                          title: const Text('Stocks'),
                                          child: ListView.separated(
                                            itemCount: transferState.sortedStocks(policy).length,
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            separatorBuilder: (_, _) {
                                              return const ShadSeparator.horizontal(margin: Pads.zero);
                                            },
                                            itemBuilder: (BuildContext context, int index) {
                                              final stock = transferState.sortedStocks(policy)[index];
                                              return Padding(
                                                padding: Pads.med(),
                                                child: Row(
                                                  spacing: Insets.sm,
                                                  children: [
                                                    Expanded(
                                                      child: SpacedText(
                                                        left: 'Purchase',
                                                        right: (stock.purchasePrice).currency(),
                                                        style: context.text.muted,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        styleBuilder: (l, r) => (l, context.text.small),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: CenterLeft(
                                                        child: ShadBadge(child: Text(stock.warehouse?.name ?? '--')),
                                                      ),
                                                    ),

                                                    CenterRight(
                                                      child: Text('${stock.quantity} ${product.unitName}'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        Padding(
                                          padding: Pads.padding(h: Insets.med, top: Insets.sm),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            spacing: Insets.lg,
                                            children: [
                                              Text.rich(
                                                TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: '${product.quantityByHouse(from?.id)} ${product.unitName}',
                                                      style: context.text.lead.textColor(
                                                        product.quantityByHouse(from?.id) > 0
                                                            ? Colors.green
                                                            : Colors.red,
                                                      ),
                                                    ),
                                                    if (quantity > 0)
                                                      TextSpan(
                                                        text: ' (-$quantity ${product.unitName})',
                                                        style: context.text.small.size(12).error(context),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            //! warehouse
                            ShadCard(
                              border: const Border(),
                              shadows: const [],
                              padding: Pads.med(),
                              childPadding: Pads.med('tb'),
                              title: const Text('Warehouse'),
                              description: const Text('Select warehouse and stock to transfer'),
                              child: warehouseList.maybeWhen(
                                orElse: () => ShadCard(padding: kDefInputPadding, child: const Loading()),
                                data: (warehouses) {
                                  return Column(
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Flexible(
                                            child: ShadSelectField<WareHouse>(
                                              name: 'from',
                                              label: 'From',
                                              hintText: 'Transfer from',
                                              initialValue: transferState.from,
                                              enabled: viewingWh.my?.isDefault == true,
                                              options: warehouses,
                                              selectedBuilder: (context, value) => Text(value.name),
                                              optionBuilder: (_, value, _) {
                                                return ShadOption(value: value, child: Text(value.name));
                                              },
                                              onChanged: (v) {
                                                selectedFrom.value = v;
                                                final changedStock = tCtrl().setFrom(v);
                                                final state = formKey.currentState!;
                                                state.patchValue(changedStock.transformValues((_, v) => '$v'));
                                              },
                                            ),
                                          ),
                                          Flexible(
                                            child: ShadSelectField<WareHouse>(
                                              label: 'To',
                                              hintText: 'Transfer destination',
                                              selectedBuilder: (context, value) => Text(value.name),
                                              options: warehouses.where((e) => e.id != selectedFrom.value?.id).toList(),
                                              optionBuilder: (_, value, _) {
                                                return ShadOption(value: value, child: Text(value.name));
                                              },
                                              onChanged: tCtrl().setTo,
                                              validators: [
                                                if (from != null)
                                                  (v) {
                                                    if (v?.id == from.id) {
                                                      return 'Transfer destination must be different';
                                                    }
                                                    return null;
                                                  },
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),

                            //! stock edit
                            StockEditSection(state: transferState),

                            Padding(
                              padding: Pads.med('lr'),
                              child: SubmitButton(
                                width: 200,
                                height: 50,
                                onPressed: (l) async {
                                  final state = formKey.currentState!;
                                  if (!state.saveAndValidate()) return;
                                  l.truthy();
                                  final res = await tCtrl().submit();
                                  l.falsey();

                                  if (context.mounted) res.showToast(context);
                                  if (res.success) {
                                    ref.invalidate(productsCtrlProvider);
                                    formKey.currentState?.reset();
                                  }
                                },
                                child: const Text('Submit'),
                              ),
                            ),
                            const Gap(Insets.med),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              if (!isMobile)
                ShadResizablePanel(
                  id: 1,
                  defaultSize: .3,
                  minSize: .2,
                  maxSize: .4,
                  child: ProductsPanel(
                    type: RecordType.sale,
                    userHouse: viewingWh.viewing,
                    onProductSelect: (p, _, w) {
                      if (p.quantity <= 0) return;
                      tCtrl().setProduct(p);
                      final changedStock = tCtrl().setFrom(w);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        final state = formKey.currentState!;
                        final value = changedStock.transformValues<dynamic>((_, v) => '$v');
                        value.addAll({'from': w});
                        state.patchValue(value);
                      });
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> _showSheet(
    BuildContext context,
    WareHouse? viewingWh,
    StockTransferCtrl Function() tCtrl,
    GlobalKey<FormBuilderState> formKey,
  ) {
    return showShadSheet(
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
          type: RecordType.sale,
          userHouse: viewingWh,
          onProductSelect: (p, _, w) {
            if (p.quantity <= 0) return;
            tCtrl().setProduct(p);
            final changedStock = tCtrl().setFrom(w);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final state = formKey.currentState!;
              final value = changedStock.transformValues<dynamic>((_, v) => '$v');
              value.addAll({'from': w});
              state.patchValue(value);
            });
            context.nPop();
          },
        ),
      ),
    );
  }
}

class StockEditSection extends HookConsumerWidget {
  const StockEditSection({super.key, required this.state});
  final StockTransferState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final StockTransferState(:product, :from) = state;

    return ShadCard(
      border: const Border(),
      shadows: const [],
      padding: Pads.med(),
      childPadding: Pads.med('tb'),
      title: const Text('Change Stock Details'),
      description: const Text('Change stock quantity and price before transfer'),
      child: LimitedWidthBox(
        maxWidth: Layouts.maxContentWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Insets.med,
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
                  ),
                ),
                Expanded(
                  child: ShadTextField(
                    name: 'quantity',
                    label: 'Quantity',
                    hintText: 'Enter Stock quantity',
                    isRequired: true,
                    initialValue: '0',
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validators: [
                      if (product != null && from != null)
                        FormBuilderValidators.max(product.quantityByHouse(from.id), checkNullOrEmpty: false),
                    ],
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
