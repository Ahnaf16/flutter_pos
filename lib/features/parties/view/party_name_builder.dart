import 'package:pos/main.export.dart';

class PartyNameBuilder extends StatelessWidget {
  const PartyNameBuilder(this.v, {super.key, this.showDue = true, this.showType = false});
  final Party v;
  final bool showDue;
  final bool showType;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: v.name),
          if (showType && !v.isWalkIn) TextSpan(text: ' (${v.type.name})', style: context.text.muted.size(12)),
          if (showDue && !v.isWalkIn)
            TextSpan(
              text: '   ${v.hasDue() ? 'Due: ' : 'Balance: '}${v.due.abs().currency()}',
              style: context.text.muted.textColor(v.dueColor()),
            ),
        ],
      ),
    );
  }
}
