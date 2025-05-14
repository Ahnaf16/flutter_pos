import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:pos/main.export.dart';

class CustomInfoFiled extends StatelessWidget {
  const CustomInfoFiled({
    super.key,
    this.name,
    this.title,
    this.initialInfo = const {},
    this.canRemoveInitial = true,
    this.header,
  });

  final String? name;
  final String? title;
  final SMap initialInfo;
  final bool canRemoveInitial;
  final Widget? Function(BuildContext context, Function() addingMethod)? header;

  @override
  Widget build(BuildContext context) {
    return FormBuilderField<List<MapEntry<String, String>>>(
      name: name ?? 'custom_info',
      initialValue: initialInfo.entries.toList(),
      valueTransformer: (value) {
        if (value == null) return [];
        final list = <String>[];
        for (final entry in value) {
          list.add('${entry.key}$kSplitPattern${entry.value}');
        }
        return list;
      },
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Insets.sm,
          children: [
            header?.call(context, () {
                  const entry = MapEntry('', '');

                  if (field.value?.contains(entry) ?? false) return;

                  field.didChange([...?field.value, entry]);
                }) ??
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title ?? 'Custom Info', style: context.theme.decoration.labelStyle),
                    ShadButton(
                      size: ShadButtonSize.sm,
                      leading: const Icon(LuIcons.plus),
                      child: const Text('Add field'),
                      onPressed: () {
                        const entry = MapEntry('', '');

                        if (field.value?.contains(entry) ?? false) return;

                        field.didChange([...?field.value, entry]);
                      },
                    ),
                  ],
                ),
            ...?field.value?.mapIndexed((i, v) {
              final showXButton = !initialInfo.containsKey(v.key) || canRemoveInitial;
              return Row(
                children: [
                  Expanded(
                    child: ShadTextField(
                      name: '${i}_key',
                      label: 'Key',
                      initialValue: v.key,
                      isRequired: true,
                      onChanged: (key) {
                        key ??= '';
                        final values = field.value?.toList();
                        if (values == null) return;
                        MapEntry<String, String> entry = values[i];
                        entry = MapEntry(key, entry.value);

                        values[i] = entry;
                        field.didChange(values);
                      },
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: ShadTextField(
                      name: '${i}_value',
                      label: 'Value',
                      initialValue: v.value,
                      isRequired: true,
                      onChanged: (value) {
                        value ??= '';
                        final values = field.value?.toList();
                        if (values == null) return;
                        MapEntry<String, String> entry = values[i];
                        entry = MapEntry(entry.key, value);

                        values[i] = entry;
                        field.didChange(values);
                      },
                      outsideTrailing:
                          !showXButton
                              ? null
                              : ShadButton.outline(
                                size: ShadButtonSize.sm,
                                leading: const Icon(LuIcons.x),
                                onPressed: () {
                                  final list =
                                      field.value?.where((e) => e != v).toList() ?? <MapEntry<String, String>>[];
                                  field.didChange(list);
                                },
                              ),
                    ),
                  ),
                ],
              );
            }),
          ],
        );
      },
    );
  }
}
