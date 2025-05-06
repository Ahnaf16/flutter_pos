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
              ShadFormField(
                name: 'name',
                label: 'Name',
                hintText: 'Enter your name',
                isRequired: true,
                initialValue: 'initial',
                showClearButton: true,
                buttonVariant: ShadButtonVariant.outline,
              ),
              ShadFormField(
                name: 'name2',
                label: 'Name 2',
                hintText: 'Enter your name 2',
                helperText: 'This is a helper text 2',
                numeric: true,
              ),
              ShadFormField(name: 'pass', label: 'pass', hintText: 'Enter your pass', isPassField: true),

              const ShadTextarea(),

              Row(
                children: [
                  ShadButton(
                    onPressed: () {
                      final state = formKey.currentState!;
                      if (!state.saveAndValidate()) return;
                      final data = state.value;
                      cat(data, 'Form Data');
                    },
                    child: const Text('Submit'),
                  ),
                  ShadButton(
                    onPressed: () {
                      formKey.currentState!.reset();
                    },
                    child: const Text('reset'),
                  ),
                  ShadButton(
                    onPressed: () {
                      formKey.currentState!.patchValue({'name': '', 'name2': '', 'pass': ''});
                    },
                    child: const Text('clear'),
                  ),
                  ShadButton(
                    onPressed: () {
                      formKey.currentState!.patchValue({'name': 'name', 'name2': 'name2', 'pass': 'pass'});
                    },
                    child: const Text('set'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
