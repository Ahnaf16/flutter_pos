import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:pos/features/products/controller/products_ctrl.dart';
import 'package:pos/features/products/controller/update_product_ctrl.dart';
import 'package:pos/features/staffs/controller/update_staff_ctrl.dart';
import 'package:pos/features/unit/controller/unit_ctrl.dart';
import 'package:pos/main.export.dart';

class CreateProductView extends HookConsumerWidget {
  const CreateProductView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updatingId = context.param('id');
    final updatingStaff = ref.watch(updateProductCtrlProvider(updatingId));
    final updateCtrl = useCallback(() => ref.read(updateProductCtrlProvider(updatingId).notifier));

    final formKey = useMemoized(GlobalKey<FormBuilderState>.new);

    // final warehouseList = ref.watch(warehouseCtrlProvider);
    final unitList = ref.watch(unitCtrlProvider);

    final searchUnit = useState('');
    // final searchWarehouse = useState('');

    final selectedFile = useState<PFile?>(null);

    final actionText = updatingId == null ? 'Create' : 'Update';

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

            (bool, String)? result;

            if (updatingId != null) {
              l.truthy();
              result = await updateCtrl().updateProduct(data, selectedFile.value);
              l.falsey();
            } else {
              l.truthy();
              final ctrl = ref.read(productsCtrlProvider.notifier);
              result = await ctrl.createProduct(data, selectedFile.value);
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
        data: (updating) {
          if (updatingId != null && updating == null) {
            return const ErrorDisplay(
              'No Product found',
              description: 'This product does not exist or has been deleted',
            );
          }

          return FormBuilder(
            key: formKey,
            initialValue: updating?.toMap() ?? {},
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
                  childSeparator: const SizedBox(width: 700, child: ShadSeparator.horizontal(thickness: 1)),
                  child: LimitedWidthBox(
                    maxWidth: 700,
                    center: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: Insets.med,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: ShadField(
                                name: 'name',
                                label: 'Name',
                                hintText: 'Enter your name',
                                isRequired: true,
                              ),
                            ),

                            Expanded(
                              child: FormBuilderField<QMap>(
                                name: 'unit',
                                validator: FormBuilderValidators.required(),
                                builder: (form) {
                                  return ShadInputDecorator(
                                    label: const Text('Choose a unit').required(),
                                    error: form.errorText == null ? null : Text(form.errorText!),
                                    decoration: context.theme.decoration.copyWith(hasError: form.hasError),
                                    child: unitList.maybeWhen(
                                      orElse: () => ShadCard(padding: kDefInputPadding, child: const Loading()),
                                      data: (roles) {
                                        final filtered = roles.where((e) => e.name.low.contains(searchUnit.value.low));
                                        return LimitedWidthBox(
                                          child: ShadSelect<ProductUnit>.withSearch(
                                            initialValue: ProductUnit.tryParse(form.value),
                                            placeholder: const Text('Unit'),
                                            options: [
                                              if (filtered.isEmpty)
                                                Padding(
                                                  padding: Pads.padding(v: 24),
                                                  child: const Text('No unit found'),
                                                ),

                                              ...filtered.map((role) {
                                                return ShadOption(value: role, child: Text(role.name));
                                              }),
                                            ],
                                            selectedOptionBuilder: (context, v) => Text(v.name),
                                            onSearchChanged: searchUnit.set,
                                            allowDeselection: true,
                                            onChanged: (v) => form.didChange(v?.toMap()),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
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
                                      if (updating?.photo case final String photo)
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

                        const Row(
                          children: [
                            Expanded(
                              child: ShadField(
                                name: 'manufacturer',
                                label: 'Manufacturer',
                                hintText: 'Enter product Manufacturer',
                              ),
                            ),
                            Expanded(
                              child: ShadField(
                                name: 'sku',
                                label: 'SKU',
                                hintText: 'Enter product SKU',
                                // outsideTrailing: SmallButton(
                                //   icon: LuIcons.refreshCcw,
                                //   onPressed: () {
                                //     final field = formKey.currentState!.fields['sku']!;
                                //     field.didChange('ID.unique()');
                                //   },
                                // ),
                              ),
                            ),
                          ],
                        ),

                        const TextArea(
                          name: 'description',
                          label: 'Description',
                          hintText: 'Enter product Description',
                          expandableHeight: true,
                          maxHeight: 400,
                        ),
                      ],
                    ),
                  ),
                ),
                // if (updatingId == null)
                //   ShadCard(
                //     border: const Border(),
                //     shadows: const [],
                //     padding: Pads.med(),
                //     childPadding: Pads.med('t'),
                //     title: const Text('Stock Details'),
                //     description: const Text('Add stock quantity and price'),
                //     childSeparator: const SizedBox(width: 700, child: ShadSeparator.horizontal(thickness: 1)),
                //     child: LimitedWidthBox(
                //       maxWidth: 700,
                //       center: false,
                //       child: Column(
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         spacing: Insets.med,
                //         children: [
                //           Row(
                //             crossAxisAlignment: CrossAxisAlignment.start,
                //             children: [
                //               Expanded(
                //                 child: ShadField(
                //                   name: 'stock.purchase_price',
                //                   label: 'Purchase Price',
                //                   hintText: 'Enter purchase price',
                //                   isRequired: true,
                //                   inputFormatters: [FilteringTextInputFormatter.allow(decimalRegExp)],
                //                 ),
                //               ),
                //               Expanded(
                //                 child: ShadField(
                //                   name: 'stock.sales_price',
                //                   label: 'Sales Price',
                //                   hintText: 'Enter sale price',
                //                   isRequired: true,
                //                   inputFormatters: [FilteringTextInputFormatter.allow(decimalRegExp)],
                //                 ),
                //               ),
                //             ],
                //           ),
                //           Row(
                //             crossAxisAlignment: CrossAxisAlignment.start,
                //             children: [
                //               Expanded(
                //                 child: ShadField(
                //                   name: 'stock.wholesale_price',
                //                   label: 'Wholesale Price',
                //                   hintText: 'Enter wholesale price',
                //                   inputFormatters: [FilteringTextInputFormatter.allow(decimalRegExp)],
                //                 ),
                //               ),
                //               Expanded(
                //                 child: ShadField(
                //                   name: 'stock.dealer_price',
                //                   label: 'Dealer Price',
                //                   hintText: 'Enter dealer price',
                //                   inputFormatters: [FilteringTextInputFormatter.allow(decimalRegExp)],
                //                 ),
                //               ),
                //               if (!context.layout.isMobile)
                //                 Expanded(
                //                   child: ShadField(
                //                     name: 'stock.quantity',
                //                     label: 'Quantity',
                //                     hintText: 'Enter Stock quantity',
                //                     isRequired: true,
                //                     inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                //                   ),
                //                 ),
                //             ],
                //           ),
                //           Row(
                //             children: [
                //               if (context.layout.isMobile)
                //                 Expanded(
                //                   child: ShadField(
                //                     name: 'stock.quantity',
                //                     label: 'Quantity',
                //                     hintText: 'Enter Stock quantity',
                //                     isRequired: true,
                //                     inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                //                   ),
                //                 ),
                //               Expanded(
                //                 flex: 2,
                //                 child: FormBuilderField<QMap>(
                //                   name: 'stock.warehouse',
                //                   validator: FormBuilderValidators.required(),
                //                   builder: (form) {
                //                     return ShadInputDecorator(
                //                       label: const Text('Choose warehouse').required(),
                //                       error: form.errorText == null ? null : Text(form.errorText!),
                //                       decoration: context.theme.decoration.copyWith(hasError: form.hasError),
                //                       child: warehouseList.maybeWhen(
                //                         orElse: () => ShadCard(padding: kDefInputPadding, child: const Loading()),
                //                         data: (warehouses) {
                //                           final filtered = warehouses.where(
                //                             (e) => e.name.low.contains(searchWarehouse.value.low),
                //                           );
                //                           return LimitedWidthBox(
                //                             child: ShadSelect<WareHouse>.withSearch(
                //                               initialValue: WareHouse.tyrParse(form.value),
                //                               placeholder: const Text('Warehouse'),
                //                               options: [
                //                                 if (filtered.isEmpty)
                //                                   Padding(
                //                                     padding: Pads.padding(v: 24),
                //                                     child: const Text('No warehouses found'),
                //                                   ),
                //                                 ...filtered.map((house) {
                //                                   return ShadOption(value: house, child: Text(house.name));
                //                                 }),
                //                               ],
                //                               selectedOptionBuilder: (context, v) => Text(v.name),
                //                               onSearchChanged: searchWarehouse.set,
                //                               allowDeselection: true,
                //                               onChanged: (v) => form.didChange(v?.toMap()),
                //                             ),
                //                           );
                //                         },
                //                       ),
                //                     );
                //                   },
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                const Gap(Insets.xl),
              ],
            ),
          );
        },
      ),
    );
  }
}
