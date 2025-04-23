import 'package:pos/main.export.dart';

class CircleImage extends StatelessWidget {
  const CircleImage(this.url, {super.key, this.padding, this.borderColor, this.radius, this.borderWidth});

  CircleImage.net(String url, {super.key, this.padding, this.borderColor, this.radius, this.borderWidth})
    : url = Img.net(url);

  CircleImage.assets(String url, {super.key, this.padding, this.borderColor, this.radius, this.borderWidth})
    : url = Img.asset(url);

  CircleImage.file(String path, {super.key, this.padding, this.borderColor, this.radius, this.borderWidth})
    : url = Img.file(path);

  CircleImage.icon(IconData icon, {super.key, this.padding, this.borderColor, this.radius, this.borderWidth})
    : url = Img.icon(icon);

  final dynamic url;
  final EdgeInsets? padding;
  final Color? borderColor;
  final double? radius;
  final double? borderWidth;

  @override
  Widget build(BuildContext context) {
    final img = url is Img ? url : Img.icon(LuIcons.imageOff);
    return DecoContainer(
      margin: padding ?? EdgeInsets.zero,
      height: (radius ?? 25) * 2,
      width: (radius ?? 25) * 2,
      clipChild: true,
      borderColor: borderColor ?? context.colors.primary,
      borderWidth: borderWidth ?? 0,
      borderRadius: 99,
      child: AspectRatio(aspectRatio: 1, child: HostedImage.square(img, dimension: (radius ?? 0) * 2)),
    );
  }
}
