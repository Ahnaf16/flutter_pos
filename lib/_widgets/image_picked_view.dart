import 'package:pos/main.export.dart';

class ImagePickedView extends StatelessWidget {
  const ImagePickedView({super.key, required this.img, this.heigh, this.width, this.size, this.onDelete});

  final FileImg img;
  final double? heigh;
  final double? width;
  final double? size;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        HostedImage(img, radius: Corners.sm, height: heigh ?? size, width: width ?? size),
        Positioned(
          top: 5,
          right: 5,
          child: ShadBadge.destructive(
            padding: Pads.xs(),
            onPressed: onDelete,
            child: Icon(LuIcons.x, size: 12, color: context.colors.destructiveForeground),
          ),
        ),
      ],
    );
  }
}
