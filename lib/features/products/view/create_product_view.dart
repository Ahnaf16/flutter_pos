import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:nanoid2/nanoid2.dart';
import 'package:pos/features/auth/controller/auth_ctrl.dart';
import 'package:pos/features/inventory_record/controller/record_editing_ctrl.dart';
import 'package:pos/features/inventory_record/view/create_record_view.dart';
import 'package:pos/features/inventory_record/view/discount_type_pop_over.dart';
import 'package:pos/features/parties/controller/parties_ctrl.dart';
import 'package:pos/features/parties/view/parties_view.dart';
import 'package:pos/features/payment_accounts/view/payment_accounts_view.dart';
import 'package:pos/features/products/controller/products_ctrl.dart';
import 'package:pos/features/products/controller/update_product_ctrl.dart';
import 'package:pos/features/staffs/controller/update_staff_ctrl.dart';
import 'package:pos/features/unit/controller/unit_ctrl.dart';
import 'package:pos/features/unit/view/unit_add_dialog.dart';
import 'package:pos/features/warehouse/controller/warehouse_ctrl.dart';
import 'package:pos/features/warehouse/view/create_warehouse_view.dart';
import 'package:pos/main.export.dart';

class CreateProductView extends HookConsumerWidget {
  const CreateProductView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updatingId = context.param('id');

    final updatingStaff = ref.watch(updateProductCtrlProvider(updatingId));
    final updateCtrl = useCallback(() => ref.read(updateProductCtrlProvider(updatingId).notifier));

    final recordCtrl = useCallback(() => ref.read(recordEditingCtrlProvider(RecordType.purchase).notifier));

    final formKey = useMemoized(GlobalKey<FormBuilderState>.new);

    final unitList = ref.watch(unitCtrlProvider);

    final selectedFile = useState<PFile?>(null);

    final updating = updatingId != null;
    final initialStock = useState(false);

    final actionText = updating ? 'Update' : 'Create';

    return BaseBody(
      title: '$actionText Product',
      scrollable: true,
      actions: [
        SubmitButton(
          size: ShadButtonSize.lg,
          child: Text(actionText),
          onPressed: (l) async {
            final state = formKey.currentState!;
            if (!state.saveAndValidate()) return;
            final data = state.value.unflattened();

            final product = Product.fromMap(data).copyWith(id: ID.unique());

            (bool, String)? result;

            if (updating) {
              l.truthy();
              result = await updateCtrl().updateProduct(data, selectedFile.value);
              l.falsey();
            } else {
              l.truthy();

              final ctrl = ref.read(productsCtrlProvider.notifier);
              result = await ctrl.createProduct(product, selectedFile.value);

              if (initialStock.value && result.success == true) {
                final stock = Stock.tryParse(data['stock'])?.copyWith(id: ID.unique());

                recordCtrl().setInputsFromMap(data['record'] ?? {});
                recordCtrl().addProduct(product, newStock: stock, replaceExisting: true);

                final (ok, msg) = await recordCtrl().submit();
                l.falsey();
                if (!ok && context.mounted) {
                  return Toast.showErr(context, msg);
                }
              }

              l.falsey();
            }

            if (result case final Result r) {
              if (!context.mounted) return;
              r.showToast(context);
              if (r.success) context.pop();
            }
          },
        ),
      ],
      body: updatingStaff.when(
        error: (e, s) => ErrorView(e, s, prov: updateStaffCtrlProvider(updatingId)),
        loading: () => const Loading(),
        data: (updateProduct) {
          if (updating && updateProduct == null) {
            return const ErrorDisplay(
              'No Product found',
              description: 'This product does not exist or has been deleted',
            );
          }

          return FormBuilder(
            key: formKey,
            initialValue: updateProduct?.toMap().transformValues((_, v) => '$v') ?? {},
            child: Column(
              spacing: Insets.lg,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShadCard(
                  border: const Border(),
                  shadows: const [],
                  padding: Pads.med(),
                  childPadding: Pads.med('t'),
                  title: const Text('Product Details'),
                  description: const Text('Add product name, description and other details'),
                  childSeparator: const SizedBox(width: 800, child: ShadSeparator.horizontal(thickness: 1)),
                  child: LimitedWidthBox(
                    maxWidth: 800,
                    center: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: Insets.med,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: ShadTextField(
                                name: 'name',
                                label: 'Name',
                                hintText: 'Enter products name',
                                isRequired: true,
                              ),
                            ),

                            Expanded(
                              child: unitList.maybeWhen(
                                orElse: () => ShadCard(padding: kDefInputPadding, child: const Loading()),
                                data: (roles) {
                                  return ShadSelectField<ProductUnit>(
                                    name: 'unit',
                                    label: 'Choose a unit',
                                    hintText: 'Unit',
                                    initialValue: updateProduct?.unit,
                                    isRequired: true,
                                    options: roles,
                                    optionBuilder: (_, v, i) => ShadOption(value: v, child: Text(v.name)),
                                    selectedBuilder: (_, v) => Text(v.name),
                                    outsideTrailing: ShadButton.outline(
                                      leading: const Icon(LuIcons.plus),
                                      onPressed: () {
                                        showShadDialog(context: context, builder: (context) => const UnitAddDialog());
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        ShadTextField(
                          name: 'sale_price',
                          label: 'Sale Price',
                          hintText: 'Enter sale price',
                          isRequired: true,
                          numeric: true,
                        ),
                        ShadInputDecorator(
                          label: const Text('Product image'),
                          child: Padding(
                            padding: Pads.padding(top: 5),
                            child: GestureDetector(
                              onTap: () async {
                                if (selectedFile.value != null) return;
                                final files = await fileUtil.pickImages(multi: false);
                                final file = files.fold(identityNull, (r) => r.firstOrNull);
                                selectedFile.set(file);
                              },
                              child: ShadCard(
                                height: 150,
                                padding: Pads.med(),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (updateProduct?.photo case final String photo)
                                        Row(
                                          spacing: Insets.med,
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            HostedImage.square(AwImg(photo), dimension: 120, radius: Corners.med),
                                            if (selectedFile.value != null) ...[
                                              const Icon(LuIcons.arrowLeftRight, size: 40),
                                              ImagePickedView(
                                                img: FileImg(selectedFile.value!),
                                                size: 120,
                                                onDelete: () => selectedFile.set(null),
                                              ),
                                            ] else
                                              const Icon(LuIcons.cloudUpload, size: 40),
                                          ],
                                        )
                                      else if (selectedFile.value != null)
                                        Row(
                                          spacing: Insets.med,
                                          children: [
                                            ImagePickedView(
                                              img: FileImg(selectedFile.value!),
                                              size: 120,
                                              onDelete: () => selectedFile.set(null),
                                            ),
                                            Text(selectedFile.value!.name, style: context.text.muted),
                                          ],
                                        )
                                      else ...[
                                        const Icon(LuIcons.cloudUpload, size: 40),
                                        Text('Drag and drop your image here', style: context.text.muted),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        Row(
                          children: [
                            Expanded(
                              child: ShadTextField(
                                name: 'manufacturer',
                                label: 'Manufacturer',
                                hintText: 'Enter product Manufacturer',
                              ),
                            ),
                            Expanded(
                              child: ShadTextField(
                                name: 'sku',
                                label: 'SKU',
                                initialValue: nanoid(length: 12),
                                hintText: 'Enter product SKU',
                                outsideTrailing: SmallButton(
                                  icon: LuIcons.refreshCcw,
                                  onPressed: () {
                                    final field = formKey.currentState!.fields['sku']!;
                                    field.didChange(nanoid(length: 12));
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),

                        ShadTextAreaField(
                          name: 'description',
                          label: 'Description',
                          hintText: 'Enter product Description',

                          maxHeight: 400,
                        ),
                      ],
                    ),
                  ),
                ),
                if (!updating)
                  ShadCheckbox(
                    value: initialStock.value,
                    onChanged: initialStock.set,
                    label: const Text('Set Initial stock'),
                  ),
                if (initialStock.value) const _InitialStock(),

                const Gap(Insets.xl),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InitialStock extends HookConsumerWidget {
  const _InitialStock();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateSyncProvider).toNullable();
    final warehouseList = ref.watch(warehouseCtrlProvider);
    final partiList = ref.watch(partiesCtrlProvider(false));

    final record = ref.watch(recordEditingCtrlProvider(RecordType.purchase));
    final recordCtrl = useCallback(() => ref.read(recordEditingCtrlProvider(RecordType.purchase).notifier));

    return ShadCard(
      border: const Border(),
      shadows: const [],
      padding: Pads.med(),
      childPadding: Pads.med('tb'),
      title: const Text('Initial stock'),
      description: const Text('Add stock quantity and price'),

      child: LimitedWidthBox(
        maxWidth: 800,
        center: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Insets.med,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: ShadTextField(
                    name: 'stock.purchase_price',
                    label: 'Purchase Price',
                    hintText: 'Enter purchase price',
                    isRequired: true,
                    numeric: true,
                  ),
                ),

                Flexible(
                  child: ShadTextField(
                    name: 'stock.quantity',
                    label: 'Quantity',
                    hintText: 'Enter Stock quantity',
                    isRequired: true,
                    initialValue: '1',
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: ShadTextField(
                    name: 'record.vat',
                    label: 'VAT',
                    hintText: 'Vat',
                    keyboardType: TextInputType.number,
                    numeric: true,
                  ),
                ),
                Expanded(
                  child: ShadTextField(
                    name: 'record.shipping',
                    label: 'Shipping',
                    hintText: 'Shipping charge',
                    keyboardType: TextInputType.number,
                    numeric: true,
                  ),
                ),
                Expanded(
                  child: ShadTextField(
                    name: 'record.discount',
                    label: 'Discount',
                    hintText: 'Discounted amount',
                    padding: kDefInputPadding.copyWith(bottom: 0, top: 0, right: 5),
                    keyboardType: TextInputType.number,
                    numeric: true,

                    trailing: DiscountTypePopOver(
                      onTypeChange: recordCtrl().changeDiscountType,
                      type: record.discountType,
                    ),
                  ),
                ),
              ],
            ),

            Row(
              children: [
                Flexible(
                  child: partiList.maybeWhen(
                    orElse: () => ShadCard(padding: kDefInputPadding, child: const Loading()),
                    data: (parties) {
                      return ShadSelectField<Party>(
                        name: 'record.supplier',
                        label: 'Supplier',
                        hintText: 'Select supplier',
                        isRequired: true,
                        options: parties,
                        selectedBuilder: (context, value) => Text(value.name),
                        optionBuilder: (_, value, _) {
                          return ShadOption(value: value, child: Text(value.name));
                        },
                        onChanged: (v) => recordCtrl().changeParti(v),
                        outsideTrailing: ShadButton.outline(
                          leading: const Icon(LuIcons.plus),
                          onPressed: () {
                            PartiesView.showAddDialog(context, false);
                          },
                        ),
                      );
                    },
                  ),
                ),
                Flexible(
                  child: warehouseList.maybeWhen(
                    orElse: () => ShadCard(padding: kDefInputPadding, child: const Loading()),
                    data: (warehouses) {
                      return ShadSelectField<WareHouse>(
                        name: 'stock.warehouse',
                        label: 'Warehouse',
                        hintText: 'Select warehouse',
                        initialValue: user?.warehouse,
                        enabled: user?.warehouse?.isDefault == true,
                        isRequired: true,
                        options: warehouses,
                        selectedBuilder: (context, value) => Text(value.name),
                        optionBuilder: (_, value, _) {
                          return ShadOption(value: value, child: Text(value.name));
                        },
                        outsideTrailing: ShadButton.outline(
                          leading: const Icon(LuIcons.plus),
                          onPressed: () {
                            showShadDialog(context: context, builder: (context) => const AddWarehouseDialog());
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: PaymentAccountSelect(
                    onAccountSelect: recordCtrl().changeAccount,
                    type: RecordType.purchase,
                    outsideTrailing: ShadButton.outline(
                      leading: const Icon(LuIcons.plus),
                      onPressed: () {
                        showShadDialog(context: context, builder: (context) => const AccountAddDialog());
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: ShadTextField(
                    name: 'record.amount',
                    hintText: 'Paid',
                    label: 'Paid amount',
                    keyboardType: TextInputType.number,
                    numeric: true,
                    isRequired: true,
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
