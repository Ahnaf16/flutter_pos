import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:pos/main.export.dart';

class HostedImage extends StatelessWidget {
  const HostedImage(
    this.img, {
    super.key,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.onImgTap,
    this.errorIcon,
    this.tag,
    this.radius = 0,
  });

  const HostedImage.square(
    this.img, {
    super.key,
    double? dimension,
    this.fit = BoxFit.cover,
    this.onImgTap,
    this.errorIcon,
    this.tag,
    this.radius = 0,
  }) : height = dimension,
       width = dimension;

  final void Function()? onImgTap;

  final IconData? errorIcon;
  final BoxFit fit;
  final double? height;
  final double? width;
  final String? tag;
  final double radius;

  /// [AssetImg], [FileImg], [NetImg], [IconImg]
  final Img img;

  @override
  Widget build(BuildContext context) {
    final loading = SizedBox(height: height, width: width, child: const Loading());
    final error = Icon(errorIcon ?? Icons.error, color: context.colors.destructive);

    if (img is AwImg) {
      final st = locate<AwStorage>();
      return FutureBuilder<Uint8List>(
        future: st.imgPreview(img.path),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return loading;
          if (snapshot.hasError) return error;

          return GestureDetector(
            onTap: onImgTap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: UniversalImage(
                snapshot.data,
                height: height,
                width: width,
                heroTag: tag ?? img.toString(),
                fit: fit,
                errorPlaceholder: error,
                placeholder: loading,
              ),
            ),
          );
        },
      );
    }

    return GestureDetector(
      onTap: onImgTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: UniversalImage(
          img.path,
          height: height,
          width: width,
          heroTag: tag ?? img.toString(),
          fit: fit,
          errorPlaceholder: error,
          placeholder: loading,
        ),
      ),
    );
  }
}

sealed class Img {
  const Img(this.path);
  final dynamic path;

  static Img from(dynamic path) => switch (path) {
    final String s when s.startsWith('http') => NetImg(s),
    final String s when s.startsWith('assets') => AssetImg(s),
    final IconData i => IconImg(i),
    final PlatformFile f => FileImg(f),
    _ => throw UnsupportedError('Unsupported image type'),
  };

  factory Img.icon(IconData icon) => IconImg(icon);

  factory Img.asset(String path) => AssetImg(path);

  factory Img.file(PlatformFile file) => FileImg(file);

  factory Img.net(String url) => NetImg(url);

  @override
  String toString() => path.toString();
}

class AssetImg extends Img {
  AssetImg(String super.path) : assert(path.startsWith('assets'), 'path must start with `assets`');
}

class FileImg extends Img {
  FileImg(PlatformFile file) : super(kIsWeb ? file.bytes : file.path);
}

class NetImg extends Img {
  NetImg(String super.url) : assert(url.startsWith(_rx), 'url must start with `http` or `https`');

  static final _rx = RegExp('(http(s)://.)');
}

class IconImg extends Img {
  IconImg(IconData super.icon);
}

class AwImg extends Img {
  AwImg(String super.fileId);
}
