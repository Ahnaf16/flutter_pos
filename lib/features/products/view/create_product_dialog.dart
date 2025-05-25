import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:nanoid2/nanoid2.dart';
import 'package:pos/features/products/controller/products_ctrl.dart';
import 'package:pos/features/unit/controller/unit_ctrl.dart';
import 'package:pos/features/unit/view/unit_add_dialog.dart';
import 'package:pos/main.export.dart';

class CreateProductDialog extends HookConsumerWidget {
  const CreateProductDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormBuilderState>.new);

    final unitList = ref.watch(unitCtrlProvider);

    final selectedFile = useState<PFile?>(null);

    return ShadDialog(
      title: const Text('Create Product'),

      actions: [
        ShadButton.destructive(onPressed: () => context.nPop(), child: const Text('Cancel')),

        SubmitButton(
          child: const Text('Create product'),
          onPressed: (l) async {
            final state = formKey.currentState!;
            if (!state.saveAndValidate()) return;
            final data = state.value.unflattened();

            final product = Product.fromMap(data).copyWith(id: ID.unique());

            l.truthy();

            final ctrl = ref.read(productsCtrlProvider.notifier);
            final (result, id) = await ctrl.createProduct(product, selectedFile.value);

            l.falsey();

            if (!context.mounted) return;
            result.showToast(context);
            if (result.success) context.pop();
          },
        ),
      ],
      child: FormBuilder(
        key: formKey,
        child: Column(
          spacing: Insets.lg,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
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
                              if (selectedFile.value != null)
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
                        initialValue: nanoid(length: 8, alphabet: '0123456789'),
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
          ],
        ),
      ),
    );
  }
}
