import 'package:favicon/favicon.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:winget_gui/helpers/package_screenshots.dart';
import 'package:winget_gui/output_handling/package_infos/package_infos_peek.dart';
import 'package:winget_gui/widget_assets/web_image.dart';

import '../output_handling/package_infos/package_infos.dart';
import '../output_handling/package_infos/package_infos_full.dart';
import 'decorated_card.dart';

String githubFaviconUrl =
    'https://github.githubassets.com/favicons/favicon.svg';

class FaviconWidget extends StatefulWidget {
  final PackageInfos infos;
  final double faviconSize;
  late final Uri? faviconUrl;
  final bool isClickable;
  final Uri? iconUrl;
  final bool withRightSiePadding;

  FaviconWidget({
    super.key,
    required this.infos,
    required this.faviconSize,
    this.isClickable = true,
    Uri? faviconUrl,
    this.iconUrl,
    this.withRightSiePadding = true,
  }) {
    if (infos is PackageInfosFull && faviconUrl == null) {
      PackageInfosFull infosFull = infos as PackageInfosFull;
      this.faviconUrl =
          infosFull.website?.value ?? infosFull.agreement?.publisher?.url;
    } else {
      this.faviconUrl = faviconUrl;
    }
  }

  factory FaviconWidget.fromFullInfos(
      PackageInfosFull infos, double faviconSize) {
    return FaviconWidget(
      infos: infos,
      faviconSize: faviconSize,
      faviconUrl: infos.website?.value ?? infos.agreement?.publisher?.url,
    );
  }

  @override
  State<FaviconWidget> createState() => _FaviconWidgetState();
}

class _FaviconWidgetState extends State<FaviconWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.withRightSiePadding? const EdgeInsets.only(right: 25): EdgeInsets.zero,
      child: DecoratedCard(
        padding: 10,
        child: SizedBox(
          width: widget.faviconSize,
          height: widget.faviconSize,
          child: Center(child: favicon()),
        ),
      ),
    );
  }

  Widget favicon() {
    PackageScreenshots? images = widget.infos.screenshots;
    if (images != null || widget.iconUrl != null) {
      String? icon;
      if (widget.iconUrl != null) {
        icon = widget.iconUrl.toString();
      } else {
        if (images!.icon != null && (images.icon.toString().isNotEmpty)) {
          icon = images.icon.toString();
        }
        if (icon == null &&
            images.backupIcon != null &&
            (images.backupIcon.toString().isNotEmpty)) {
          icon = images.backupIcon.toString();
        }
      }
      if (icon != null) {
        return loadFavicon(
          widget.faviconSize,
          icon,
          () {
            if (icon != images?.backupIcon.toString() &&
                images?.backupIcon != null &&
                (images?.backupIcon.toString().isNotEmpty ?? false)) {
              return loadFavicon(
                  widget.faviconSize, images!.backupIcon.toString(), () {
                if (widget.infos.publisherIcon != null &&
                    widget.infos.publisherIcon.toString().isNotEmpty) {
                  return loadFavicon(
                      widget.faviconSize,
                      widget.infos.publisherIcon.toString(),
                      () => defaultFavicon(),
                      color: defaultColor());
                }
                return defaultFavicon();
              });
            }
            return findFavicon();
          },
        );
      }
      if (widget.infos.publisherIcon != null &&
          widget.infos.publisherIcon.toString().isNotEmpty) {
        return loadFavicon(widget.faviconSize,
            widget.infos.publisherIcon.toString(), () => defaultFavicon(),
            color: defaultColor());
      }
    }
    if (widget.infos.publisherIcon != null &&
        widget.infos.publisherIcon.toString().isNotEmpty) {
      return loadFavicon(widget.faviconSize,
          widget.infos.publisherIcon.toString(), () => defaultFavicon(),
          color: defaultColor());
    }
    return findFavicon();
  }

  Widget findFavicon() {
    return FutureBuilder<Favicon?>(
      future: FaviconFinder.getBest(widget.faviconUrl.toString()),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Favicon? favicon = snapshot.data;
          if (favicon != null && favicon.url != githubFaviconUrl) {
            if (kDebugMode) {
              print(favicon.url);
            }
            return loadFavicon(
                widget.faviconSize, favicon.url, () => defaultFavicon());
          }
        }
        return defaultFavicon();
      },
    );
  }

  Widget defaultFavicon() {
    return Icon(
      FluentIcons.product,
      size: widget.faviconSize,
      color: defaultColor(),
    );
  }

  Color defaultColor() {
    return FluentTheme.of(context)
        .inactiveColor
        .withAlpha(widget.isClickable ? 100 : 50);
  }

  Widget loadFavicon(double faviconSize, String url, Widget Function() onError,
      {Color? color}) {
    Widget image;

    image = WebImage(
      url: url,
      imageHeight: faviconSize,
      imageWidth: faviconSize,
      isHalfTransparent: !widget.isClickable,
      imageConfig: ImageConfig(
        filterQuality: FilterQuality.high,
        isAntiAlias: true,
        errorBuilder: (context, error, stackTrace) {
          return onError();
        },
        //loadingBuilder: (context) {
        //  return defaultFavicon();
        //},
        solidColor: color,
      ),
    );
    return image;
  }
}

class DefaultFavicon extends FaviconWidget {
  DefaultFavicon(
      {super.key, required super.faviconSize, super.isClickable = true})
      : super(infos: PackageInfosPeek()..screenshots = null, faviconUrl: null);
}
