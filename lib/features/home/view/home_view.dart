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
              ShadTextField(
                name: 'regular',
                label: 'Regular',
                hintText: 'Regular input',
                isRequired: true,
                initialValue: 'initial value',
                showClearButton: true,
              ),
              ShadTextField(
                name: 'numeric',
                label: 'numeric',
                hintText: 'numeric input',
                helperText: 'This is a numeric field',
                numeric: true,
              ),
              ShadTextField(name: 'pass', label: 'pass', hintText: 'Enter your pass', isPassField: true),

              ShadTextAreaField(
                name: 'desc',
                label: 'desc',
                hintText: 'Enter your desc',
                isRequired: true,
                initialValue: 'initial value',
              ),

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
                      formKey.currentState!.patchValue({'regular': '', 'numeric': '', 'pass': '', 'desc': ''});
                    },
                    child: const Text('clear'),
                  ),
                  ShadButton(
                    onPressed: () {
                      formKey.currentState!.patchValue({
                        'regular': 'Regular',
                        'numeric': '12587854',
                        'pass': 'password',
                        'desc': 'description',
                      });
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
