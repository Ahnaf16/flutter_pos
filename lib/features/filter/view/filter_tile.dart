import 'package:pos/main.export.dart';

class FilterTile extends HookWidget {
  const FilterTile({super.key, required this.leading, required this.text, this.onPressed});
  final IconData leading;
  final String text;
  final Function()? onPressed;
  @override
  Widget build(BuildContext context) {
    final hovering = useState(false);

    return ShadGestureDetector(
      onTap: onPressed,
      onHoverChange: (value) => hovering.value = value,
      child: DecoContainer(
        padding: Pads.sm(),
        color: hovering.value ? context.colors.border : Colors.transparent,
        borderRadius: Corners.sm,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            Icon(leading),
            Text(text),
            const Spacer(),
            if (hovering.value) const Icon(LuIcons.chevronRight),
          ],
        ),
      ),
    );
  }
}

class FilterTileSelectable<T> extends HookWidget {
  const FilterTileSelectable({
    super.key,
    required this.value,
    required this.text,
    this.onPressed,
    this.selected = false,
  });

  final T value;
  final bool selected;
  final String text;
  final Function()? onPressed;
  @override
  Widget build(BuildContext context) {
    final hovering = useState(false);

    return ShadGestureDetector(
      onTap: onPressed,
      onHoverChange: (value) => hovering.value = value,
      child: DecoContainer(
        padding: Pads.sm(),
        color: hovering.value ? context.colors.border : Colors.transparent,
        borderRadius: Corners.sm,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            Icon(
              selected ? LuIcons.circleCheckBig : LuIcons.circle,
              color: selected ? context.colors.primary : null,
            ),
            Text(text, style: context.text.small.textColor(selected ? context.colors.primary : null)),
          ],
        ),
      ),
    );
  }
}
