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
      body: SingleChildScrollView(
        child: FormBuilder(
          key: formKey,
          child: const Column(
            spacing: Insets.lg,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Gap(Insets.xl)],
          ),
        ),
      ),
    );
  }
}
