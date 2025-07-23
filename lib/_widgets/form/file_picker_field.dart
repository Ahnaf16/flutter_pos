import 'package:fpdart/fpdart.dart';
import 'package:pos/main.export.dart';

class FilePickerField extends StatelessWidget {
  const FilePickerField({
    super.key,
    this.selectedFile,
    required this.onSelect,
    this.compact = false,
    this.title,
    this.subtitle,
  });

  final Function(PFile? file) onSelect;
  final PFile? selectedFile;
  final bool compact;
  final String? title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      border: const Border(),
      shadows: const [],

      title: Text(title ?? 'Upload File', style: context.text.p),
      description: subtitle == null ? null : Text(subtitle!, style: context.text.muted),
      padding: Pads.zero,
      childPadding: Pads.xs('t'),
      child: ShadDottedBorder(
        color: context.colors.foreground.op3,
        child: Center(
          child: Flex(
            direction: compact ? Axis.horizontal : Axis.vertical,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (selectedFile == null) ...[
                const ShadAvatar(LuIcons.upload),
                const Gap(Insets.med),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: compact ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                  children: [
                    const Text('Drag and drop files here'),
                    Text('Or click browse (max 3MB)', style: context.text.muted.size(12)),
                  ],
                ),
                const Gap(Insets.med),
                ShadButton.outline(
                  size: ShadButtonSize.sm,
                  child: const SelectionContainer.disabled(child: Text('Browse Files')),
                  onPressed: () async {
                    if (selectedFile != null) return;
                    final files = await fileUtil.pickSingleFile();
                    final file = files.fold(identityNull, identity);
                    onSelect(file);
                  },
                ),
              ] else
                FileTIle(file: right(selectedFile!), onClear: () => onSelect(null)).conditionalExpanded(compact),
            ],
          ),
        ),
      ),
    );
  }
}

class FileTIle extends StatelessWidget {
  const FileTIle({
    super.key,
    required this.file,
    required this.onClear,
  });

  final Either<AwFile, PFile> file;

  final Function() onClear;

  @override
  Widget build(BuildContext context) {
    final name = file.fold((l) => l.name, (r) => r.name);
    final size = file.fold((l) => l.size, (r) => r.size.readableByte());
    return Row(
      spacing: Insets.med,
      children: [
        const ShadAvatar(LuIcons.file),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: context.text.list),
              Text(size, style: context.text.muted),
            ],
          ),
        ),

        if (file.isRight())
          ShadIconButton(
            icon: const Icon(LuIcons.x),
            onPressed: () => onClear(),
          ).colored(context.colors.destructive)
        else
          ShadIconButton(
            icon: const Icon(LuIcons.download),
            onPressed: () => file.fold((l) => l.download(), (_) {}),
          ).colored(context.colors.primary),
      ],
    );
  }
}
