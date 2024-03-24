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
      return Image.network(url,
          width: imageWidth,
          height: imageWidth,
          filterQuality: imageConfig.filterQuality,
          isAntiAlias: imageConfig.isAntiAlias,
          errorBuilder: imageConfig.errorBuilder,
          frameBuilder: imageConfig.loadingBuilder != null
              ? (context, _, __, ___) => imageConfig.loadingBuilder!(context)
              : null,
          fit: BoxFit.contain,
          color: color(),
          colorBlendMode: colorBlendMode());
    }
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
  final Widget Function(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  )? errorBuilder;
  final Color? solidColor;
  final Widget Function(BuildContext)? loadingBuilder;

  const ImageConfig({
    this.filterQuality = FilterQuality.high,
    this.isAntiAlias = true,
    this.errorBuilder,
    this.loadingBuilder,
    this.solidColor,
  });
}
