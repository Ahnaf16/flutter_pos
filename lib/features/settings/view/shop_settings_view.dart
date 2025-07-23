import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:pos/features/settings/controller/settings_ctrl.dart';
import 'package:pos/main.export.dart';

class ShopSettingsView extends HookConsumerWidget {
  const ShopSettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configData = ref.watch(configCtrlAsyncProvider);
    final shopCtrl = useCallback(() => ref.read(configCtrlAsyncProvider.notifier));

    final formKey = useMemoized(GlobalKey<FormBuilderState>.new);

    final selectedFile = useState<PFile?>(null);

    return configData.when(
      error: (e, s) => ErrorView(e, s, prov: configCtrlAsyncProvider),
      loading: () => const Loading(),
      data: (config) {
        return ShadCard(
          border: const Border(),
          shadows: const [],
          padding: Pads.med(),
          childPadding: Pads.med('t'),
          title: const Text('Shop config'),
          description: const Text('Configure shop settings'),
          child: SingleChildScrollView(
            child: LimitedWidthBox(
              center: false,
              maxWidth: 700,
              child: FormBuilder(
                key: formKey,
                initialValue: config.toMap(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: Insets.med,
                  children: [
                    const Gap(Insets.sm),
                    ShadTextField(name: 'shop_name', label: 'Shop name', hintText: 'Enter your shop name'),
                    ShadTextAreaField(name: 'shop_address', label: 'Shop address', hintText: 'Enter your shop address'),

                    ShadCard(
                      title: Text('Shop logo', style: context.text.p),
                      padding: Pads.xl().copyWith(top: Insets.med),
                      childPadding: Pads.med('t'),
                      width: 700,
                      child: ShadDottedBorder(
                        child: Center(
                          child: Column(
                            children: [
                              if (config.shop.shopLogo != null || selectedFile.value != null)
                                Row(
                                  spacing: Insets.med,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (config.shop.shopLogo != null)
                                      Stack(
                                        children: [
                                          HostedImage.square(
                                            AwImg(config.shop.shopLogo!),
                                            dimension: 120,
                                            radius: Corners.med,
                                          ),
                                          Positioned(
                                            top: 5,
                                            right: 5,
                                            child: ShadBadge.secondary(
                                              padding: Pads.xs(),
                                              onPressed: () async {
                                                final files = await fileUtil.pickImages(multi: false);
                                                final file = files.fold(identityNull, (r) => r.firstOrNull);
                                                selectedFile.set(file);
                                              },
                                              child: const Icon(LuIcons.pen, size: 12),
                                            ),
                                          ),
                                        ],
                                      ),
                                    if (config.shop.shopLogo != null && selectedFile.value != null)
                                      const Icon(LuIcons.arrowRight, size: 20),
                                    if (selectedFile.value != null) ...[
                                      ImagePickedView(
                                        img: FileImg(selectedFile.value!),
                                        size: 120,
                                        onDelete: () => selectedFile.set(null),
                                      ),
                                    ],
                                  ],
                                )
                              else ...[
                                const ShadAvatar(LuIcons.upload),
                                const Gap(Insets.med),
                                const Text('Drag and drop files here'),
                                Text('Or click browse (max 3MB)', style: context.text.muted.size(12)),
                                const Gap(Insets.med),
                                ShadButton.outline(
                                  size: ShadButtonSize.sm,
                                  child: const SelectionContainer.disabled(child: Text('Browse Files')),
                                  onPressed: () async {
                                    if (selectedFile.value != null) return;
                                    final files = await fileUtil.pickImages(multi: false);
                                    final file = files.fold(identityNull, (r) => r.firstOrNull);
                                    selectedFile.set(file);
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),

                    const Gap(Insets.med),
                    SubmitButton(
                      child: const Text('Update shop'),
                      onPressed: (l) async {
                        final state = formKey.currentState!;
                        if (!state.saveAndValidate()) return;
                        final data = config.marge(state.value);

                        l.truthy();
                        final result = await shopCtrl().updateConfig(data, selectedFile.value);
                        l.falsey();

                        if (result case final Result r) {
                          state.reset();
                          selectedFile.set(null);
                          if (!context.mounted) return;
                          r.showToast(context);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
