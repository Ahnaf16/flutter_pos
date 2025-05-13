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
    final address = userOrParti.fold(identityNull, (r) => r?.address);
    final isWalkIn = userOrParti.fold(identityNull, (r) => r?.isWalkIn);
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
                  spaced: false,
                  crossAxisAlignment: CrossAxisAlignment.center,
                ),

                SpacedText(
                  left: 'Phone',
                  right: phone ?? '--',
                  styleBuilder: (l, r) => (l, r.bold),
                  spaced: false,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  onTap: (left, right) => Copier.copy(right),
                ),
                if (isWalkIn ?? false) ShadBadge.secondary(child: Text('Walk-In', style: context.text.muted)),
                if (email != null)
                  SpacedText(
                    left: 'Email',
                    right: email,
                    styleBuilder: (l, r) => (l, r.bold),
                    spaced: false,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    onTap: (left, right) => Copier.copy(right),
                  ),
                if (address != null)
                  SpacedText(
                    left: 'Address',
                    right: address,
                    styleBuilder: (l, r) => (l, r.bold),
                    spaced: false,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    onTap: (left, right) => Copier.copy(right),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
