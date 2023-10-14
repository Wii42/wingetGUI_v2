import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_svg/svg.dart';

class WebImage extends StatelessWidget {
  final String url;
  final double? imageHeight;
  final double? imageWidth;
  final ImageConfig imageConfig;

  const WebImage({
    super.key,
    required this.url,
    this.imageHeight,
    this.imageWidth,
    this.imageConfig = const ImageConfig(),
  });

  @override
  Widget build(BuildContext context) {
    String imageType = url.substring(url.lastIndexOf('.') + 1);

    if (imageType == 'svg') {
      return SvgPicture.network(
        url,
        width: imageWidth,
        height: imageHeight,
      );
    } else {
      return Image.network(
        url,
        width: imageWidth,
        height: imageWidth,
        filterQuality: imageConfig.filterQuality,
        isAntiAlias: imageConfig.isAntiAlias,
        errorBuilder: imageConfig.errorBuilder,
      );
    }
  }
}

class ImageConfig {
  final FilterQuality filterQuality;
  final bool isAntiAlias;
  final Widget Function(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  )? errorBuilder;

  const ImageConfig({
    this.filterQuality = FilterQuality.high,
    this.isAntiAlias = true,
    this.errorBuilder,
  });
}
