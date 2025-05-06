import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:pos/features/auth/controller/auth_ctrl.dart';
import 'package:pos/features/staffs/controller/update_staff_ctrl.dart';
import 'package:pos/main.export.dart';
import 'package:pos/routes/page/protected_page.dart';

class ProfileView extends HookConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.watch(currentUserProvider);
    final selectedFile = useState<PFile?>(null);

    final formKey = useMemoized(GlobalKey<FormBuilderState>.new);

    return ShadCard(
      border: const Border(),
      shadows: const [],
      padding: Pads.med(),
      childPadding: Pads.med('t'),
      title: const Text('Profile'),
      description: const Text('This is how others see you'),
      child: userData.when(
        error: (e, s) => ErrorView(e, s, prov: currentUserProvider),
        loading: () => const Loading(),
        data: (user) {
          if (user == null) return ProtectedPage.body(context, false);
          return SingleChildScrollView(
            child: LimitedWidthBox(
              center: false,
              maxWidth: 700,
              child: FormBuilder(
                key: formKey,
                initialValue: user.toMap(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: Insets.med,
                  children: [
                    const Gap(Insets.sm),
                    Row(
                      spacing: Insets.med,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          children: [
                            if (user.photo case final String photo)
                              HostedImage.square(AwImg(photo), dimension: 120, radius: Corners.med)
                            else
                              ShadCard(
                                expanded: false,
                                padding: Pads.zero,
                                child: HostedImage.square(
                                  IconImg(LuIcons.user, 20),
                                  dimension: 120,
                                  radius: Corners.med,
                                ),
                              ),
                            Positioned(
                              top: 5,
                              right: 5,
                              child: ShadBadge.secondary(
                                padding: Pads.xs(),
                                onPressed: () async {
                                  if (selectedFile.value != null) return;
                                  final files = await fileUtil.pickImages(multi: false);
                                  final file = files.fold(identityNull, (r) => r.firstOrNull);
                                  selectedFile.set(file);
                                },
                                child: const Icon(LuIcons.pen, size: 12),
                              ),
                            ),
                          ],
                        ),
                        if (selectedFile.value != null) ...[
                          const Icon(LuIcons.arrowRight, size: 20),
                          ImagePickedView(
                            img: FileImg(selectedFile.value!),
                            size: 120,
                            onDelete: () => selectedFile.set(null),
                          ),
                        ],
                      ],
                    ),
                    ShadFormField(name: 'name', label: 'Name', hintText: 'Enter your name', isRequired: true),

                    ShadFormField(
                      name: 'email',
                      label: 'Email',
                      hintText: 'Enter your email',
                      isRequired: true,
                      enabled: false,
                      helperText: 'Email is not editable',
                    ),

                    ShadFormField(name: 'phone', label: 'Phone', hintText: 'Enter your phone', isRequired: true),

                    const Gap(Insets.med),
                    SubmitButton(
                      child: const Text('Update profile'),
                      onPressed: (l) async {
                        final state = formKey.currentState!;
                        if (!state.saveAndValidate()) return;
                        final data = state.value;

                        l.truthy();
                        final ctrl = ref.read(updateStaffCtrlProvider(user.id).notifier);
                        final result = await ctrl.updateStaff(data, selectedFile.value);
                        l.falsey();

                        if (result case final Result r) {
                          if (!context.mounted) return;
                          selectedFile.set(null);
                          r.showToast(context);
                          ref.invalidate(currentUserProvider);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
