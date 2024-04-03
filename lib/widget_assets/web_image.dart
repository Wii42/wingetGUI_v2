import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_svg/svg.dart';

import '../helpers/log_stream.dart';

const double opacity = 0.5;
const opaqueWhite = Color.fromRGBO(255, 255, 255, opacity);

class WebImage extends StatelessWidget {
  late final Logger log;

  final String url;
  final double? imageHeight;
  final double? imageWidth;
  final ImageConfig imageConfig;
  final bool isHalfTransparent;

  WebImage({
    super.key,
    required this.url,
    this.imageHeight,
    this.imageWidth,
    this.imageConfig = const ImageConfig(),
    this.isHalfTransparent = false,
  }) {
    log = Logger(this);
    log.info(url);
  }

  @override
  Widget build(BuildContext context) {
    String imageType = url.substring(url.lastIndexOf('.') + 1);
    if (imageType == 'svg') {
      return SvgPicture.network(url,
          width: imageWidth,
          height: imageHeight,
          placeholderBuilder: imageConfig.loadingBuilder,
          colorFilter: colorFilter());
    } else {
      return CachedNetworkImage(
        imageUrl: url,
        width: imageWidth,
        height: imageWidth,
        filterQuality: imageConfig.filterQuality,
        errorWidget: imageConfig.errorBuilder,
        placeholder: imageConfig.loadingBuilder != null
            ? (context, _) => imageConfig.loadingBuilder!(context)
            : null,
        fit: BoxFit.contain,
        color: color(),
        colorBlendMode: colorBlendMode(),
        memCacheWidth: ratio <= 1 ? calculatePixels(imageWidth, context) : null,
        memCacheHeight:
            ratio > 1 ? calculatePixels(imageHeight, context) : null,
        errorListener: (object) => log.error(object.toString()),
        fadeInDuration: const Duration(milliseconds: 0),
        fadeOutDuration: const Duration(milliseconds: 0),
      );
    }
  }

  /// Returns the ratio of the image width to the image height.
  /// If the image is taller than it is wide, the ratio will be smaller than 1.
  /// if either the image width or height is null, the ratio will be 1.
  double get ratio => imageWidth != null && imageHeight != null
      ? imageWidth! / imageHeight!
      : 1;

  static int? calculatePixels(double? imageDimension, BuildContext context) {
    if (imageDimension == null) {
      return null;
    }
    return (imageDimension * MediaQuery.of(context).devicePixelRatio).round();
  }

  BlendMode? colorBlendMode() {
    if (imageConfig.solidColor != null) {
      return BlendMode.srcIn;
    }
    return isHalfTransparent ? BlendMode.modulate : null;
  }

  Color? color() {
    if (imageConfig.solidColor != null) {
      Color color = imageConfig.solidColor!;
      return isHalfTransparent
          ? color.withOpacity(opacity * color.opacity)
          : color;
    }
    return isHalfTransparent ? opaqueWhite : null;
  }

  ColorFilter? colorFilter() {
    if (imageConfig.solidColor != null) {
      Color color = imageConfig.solidColor!;
      return isHalfTransparent
          ? ColorFilter.mode(
              color.withOpacity(opacity * color.opacity), BlendMode.srcIn)
          : ColorFilter.mode(color, BlendMode.srcIn);
    }
    return isHalfTransparent
        ? const ColorFilter.mode(opaqueWhite, BlendMode.modulate)
        : null;
  }
}

class ImageConfig {
  final FilterQuality filterQuality;
  final bool isAntiAlias;
  final Widget Function(BuildContext context, String string, Object object)?
      errorBuilder;
  final Color? solidColor;
  final Widget Function(BuildContext context)? loadingBuilder;

  const ImageConfig({
    this.filterQuality = FilterQuality.high,
    this.isAntiAlias = true,
    this.errorBuilder,
    this.loadingBuilder,
    this.solidColor,
  });
}
