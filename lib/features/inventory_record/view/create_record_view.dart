import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:pos/main.export.dart';

class CreateRecordView extends HookConsumerWidget {
  const CreateRecordView({super.key, required this.type});
  final RecordType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormBuilderState>.new);

    return BaseBody(
      title: 'Create Inventory Record',
      actions: [
        SubmitButton(
          size: ShadButtonSize.lg,
          child: const Text('Create'),
          onPressed: (l) async {
            final state = formKey.currentState!;
            if (!state.saveAndValidate()) return;
            final data = state.value;

            cat(data, 'FORM');
          },
        ),
      ],
      body: Row(
        spacing: Insets.sm,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              spacing: Insets.sm,
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Row(
                  children: [
                    ShadSelect<int>.withSearch(
                      itemCount: 20,
                      maxWidth: 300,
                      minWidth: 300,
                      placeholder: const Text('parti'),
                      optionsBuilder: (_, i) => ShadOption<int>(value: i, child: Text('$i')),
                      selectedOptionBuilder: (_, v) => Text(v.toString()),
                      onSearchChanged: (value) {},
                    ),
                    ShadIconButton.outline(height: 38, icon: const Icon(LuIcons.plus), onPressed: () {}),
                  ],
                ),
                Expanded(
                  child: ShadCard(
                    padding: Pads.zero,
                    child: ShadResizablePanelGroup(
                      axis: Axis.vertical,
                      showHandle: true,
                      children: [
                        ShadResizablePanel(
                          id: 0,
                          defaultSize: 0.7,
                          child: Padding(
                            padding: Pads.sm('b'),
                            child: ListView.separated(
                              padding: Pads.sm(),
                              itemCount: 30,
                              separatorBuilder: (_, _) => const Gap(Insets.med),
                              itemBuilder: (BuildContext context, int index) {
                                return _box('$index', 50);
                              },
                            ),
                          ),
                        ),
                        ShadResizablePanel(
                          id: 1,
                          defaultSize: 0.3,
                          minSize: 0.1,
                          child: SingleChildScrollView(
                            padding: Pads.sm(),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: Insets.sm,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    spacing: Insets.sm,
                                    children: [
                                      const Row(
                                        children: [
                                          Expanded(flex: 2, child: ShadField(hintText: 'Amount')),
                                          Expanded(child: ShadField(hintText: 'Vat')),
                                        ],
                                      ),

                                      const Row(
                                        children: [
                                          Expanded(child: ShadField(hintText: 'Discount')),
                                          Expanded(child: ShadField(hintText: 'Shipping')),
                                        ],
                                      ),
                                      ShadSelect<int>(
                                        itemCount: 5,
                                        maxWidth: 300,
                                        minWidth: 300,
                                        placeholder: const Text('account'),
                                        optionsBuilder: (_, i) => ShadOption<int>(value: i, child: Text('$i')),
                                        selectedOptionBuilder: (_, v) => Text(v.toString()),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 200, child: ShadSeparator.vertical()),
                                Expanded(
                                  child: Column(
                                    spacing: Insets.sm,
                                    children: [
                                      SpacedText(
                                        left: 'Subtotal',
                                        right: 10000.currency(),
                                        styleBuilder: (l, r) => (l, r.bold),
                                      ),
                                      SpacedText(
                                        left: 'Total',
                                        right: 10000.currency(),
                                        styleBuilder: (l, r) => (l, context.text.large),
                                      ),
                                      SpacedText(left: 'Due', right: 0.currency(), styleBuilder: (l, r) => (l, r.bold)),
                                      const Gap(Insets.xs),
                                      SubmitButton(
                                        width: double.infinity,
                                        onPressed: (l) {},
                                        child: const Text('Submit'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              spacing: Insets.med,
              children: [
                const ShadInput(placeholder: Text('Search')),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: Insets.sm,
                      crossAxisSpacing: Insets.sm,
                    ),
                    itemCount: 20,
                    itemBuilder: (context, index) {
                      return _box('${index + 1}');
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _box(String name, [double? size]) {
    return DecoContainer(
      size: size,
      color: Colors.grey.shade800,
      borderRadius: Corners.med,
      alignment: Alignment.center,
      child: Text(name),
    );
  }
}
