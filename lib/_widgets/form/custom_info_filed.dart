import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:pos/main.export.dart';

typedef CustomInfo = List<MapEntry<String, String>>;

class CustomInfoFiled extends HookWidget {
  const CustomInfoFiled({
    super.key,
    this.name,
    this.title,
    this.initialInfo,
    this.fixedInitialField = const {},
    this.header,
  });

  final String? name;
  final String? title;
  final SMap? initialInfo;
  final SMap fixedInitialField;
  final Widget? Function(BuildContext context, VoidCallback addingMethod)? header;

  void _addingMethod(FormFieldState<CustomInfo> field) {
    const entry = MapEntry('', '');
    if (field.value?.contains(entry) ?? false) return;
    field.didChange([...?field.value, entry]);
  }

  @override
  Widget build(BuildContext context) {
    final initials = {...fixedInitialField, ...?initialInfo};

    return FormBuilderField<CustomInfo>(
      name: name ?? 'custom_info',
      initialValue: initials.entries.toList(),
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
            header?.call(context, () => _addingMethod(field)) ??
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title ?? 'Custom Info', style: context.theme.decoration.labelStyle),
                    ShadButton(
                      size: ShadButtonSize.sm,
                      leading: const Icon(LuIcons.plus),
                      child: const SelectionContainer.disabled(child: Text('Add field')),
                      onPressed: () => _addingMethod(field),
                    ),
                  ],
                ),
            ...?field.value?.mapIndexed((i, v) {
              final showXButton = !fixedInitialField.containsKey(v.key);
              return Row(
                children: [
                  Expanded(
                    child: ShadTextField(
                      name: '${i}_key',
                      hintText: 'Key',
                      initialValue: v.key,
                      isRequired: showXButton,
                      readOnly: !showXButton,
                      focusNode: showXButton ? null : FocusNode(skipTraversal: true, canRequestFocus: false),
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
                      hintText: 'Value',
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
                      outsideTrailing: !showXButton
                          ? null
                          : ShadButton.outline(
                              size: ShadButtonSize.sm,
                              leading: const Icon(LuIcons.x),
                              onPressed: () {
                                final list = field.value?.where((e) => e != v).toList() ?? <MapEntry<String, String>>[];
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
