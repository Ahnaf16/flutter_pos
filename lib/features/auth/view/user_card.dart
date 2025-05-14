import 'package:fpdart/fpdart.dart';
import 'package:pos/main.export.dart';

class UserCard extends StatelessWidget {
  const UserCard({super.key, required this.userOrParti, this.title, this.subtitle, this.imgSize = 50});
  UserCard.user({super.key, required AppUser user, this.title, this.subtitle, this.imgSize = 50})
    : userOrParti = left(user);
  UserCard.parti({super.key, required Party? parti, this.title, this.subtitle, this.imgSize = 50})
    : userOrParti = right(parti);

  final Either<AppUser, Party?> userOrParti;
  final String? title;
  final String? subtitle;
  final double imgSize;

  @override
  Widget build(BuildContext context) {
    final photo = userOrParti.fold((l) => l.getPhoto, (r) => r?.getPhoto);
    final name = userOrParti.fold((l) => l.name, (r) => r?.name);
    final phone = userOrParti.fold((l) => l.phone, (r) => r?.phone);
    final email = userOrParti.fold((l) => l.email, (r) => r?.email);
    final hasDue = userOrParti.fold(identityNull, (r) => r?.hasDue());
    final due = userOrParti.fold(identityNull, (r) => r?.due);
    return ShadCard(
      title: title == null ? null : Text(title!, style: context.theme.decoration.labelStyle),
      description: subtitle == null ? null : Text(subtitle!, style: context.theme.decoration.descriptionStyle),
      childPadding: Pads.sm('t'),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: Insets.med,
        children: [
          if (photo != null)
            ShadCard(
              expanded: false,
              height: imgSize,
              width: imgSize,
              padding: Pads.zero,
              child: FittedBox(child: HostedImage.square(photo, dimension: imgSize)),
            ),
          Flexible(
            child: Column(
              spacing: Insets.sm,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SpacedText(
                  left: 'Name',
                  right: name ?? '--',
                  styleBuilder: (l, r) => (l, r.bold),
                  crossAxisAlignment: CrossAxisAlignment.center,
                ),

                SpacedText(
                  left: 'Phone',
                  right: phone ?? '--',
                  styleBuilder: (l, r) => (l, r.bold),
                  crossAxisAlignment: CrossAxisAlignment.center,
                  onTap: (left, right) => Copier.copy(right),
                ),

                if (email != null)
                  SpacedText(
                    left: 'Email',
                    right: email,
                    styleBuilder: (l, r) => (l, r.bold),
                    crossAxisAlignment: CrossAxisAlignment.center,
                    onTap: (left, right) => Copier.copy(right),
                  ),

                if (hasDue != null && due != null)
                  SpacedText(
                    left: hasDue ? 'Due' : 'Balance',
                    right: due.abs().currency(),
                    style: context.text.list,
                    styleBuilder: (l, r) => (l, r.bold.textColor(hasDue ? Colors.red : Colors.green)),
                    crossAxisAlignment: CrossAxisAlignment.center,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
