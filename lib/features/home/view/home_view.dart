import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:pos/main.export.dart';

class HomeView extends HookConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: context.layout.pagePadding,
        child: FormBuilder(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 20,
            children: [
              const ShadField(
                name: 'name',
                label: 'Name',
                hintText: 'Enter your name',
                helperText: 'This is a helper text',
                isRequired: true,
                initialValue: 'initial',
              ),
              const TextArea(
                expandableHeight: true,
                isRequired: true,
                name: 'test',
                label: 'Name',
                hintText: 'Enter your name',
                helperText: 'This is a helper text',
              ),
              ShadButton(
                onPressed: () {
                  final state = formKey.currentState!;
                  if (!state.saveAndValidate()) return;
                  final data = state.value;
                  cat(data, 'Form Data');
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
