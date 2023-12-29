import 'package:favicon/favicon.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/output_handling/package_infos/package_infos_peek.dart';
import 'package:winget_gui/widget_assets/web_image.dart';

import '../output_handling/package_infos/package_infos.dart';
import '../output_handling/package_infos/package_infos_full.dart';
import 'decorated_card.dart';

class FaviconWidget extends StatefulWidget {
  final PackageInfos infos;
  final double faviconSize;
  late final Uri? faviconUrl;

  FaviconWidget(
      {super.key,
      required this.infos,
      required this.faviconSize,
      Uri? faviconUrl}) {
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
      padding: const EdgeInsets.only(right: 25),
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
    if (widget.infos.screenshots?.icon != null &&
        (widget.infos.screenshots!.icon.toString().isNotEmpty)) {
      return loadFavicon(widget.faviconSize,
          widget.infos.screenshots!.icon.toString(), () => findFavicon());
    }
    return findFavicon();
  }

  Widget findFavicon() {
    return FutureBuilder<Favicon?>(
      future: FaviconFinder.getBest(widget.faviconUrl.toString()),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Favicon? favicon = snapshot.data;
          if (favicon != null) {
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
      color: FluentTheme.of(context).inactiveColor.withAlpha(100),
    );
  }

  Widget loadFavicon(
      double faviconSize, String url, Widget Function() onError) {
    Widget image;

    image = WebImage(
      url: url,
      imageHeight: faviconSize,
      imageWidth: faviconSize,
      imageConfig: ImageConfig(
        filterQuality: FilterQuality.high,
        isAntiAlias: true,
        errorBuilder: (context, error, stackTrace) {
          return onError();
        },
        //loadingBuilder: (context) {
        //  return defaultFavicon();
        //},
      ),
    );
    return image;
  }
}

class DefaultFavicon extends FaviconWidget {
  DefaultFavicon({super.key, required super.faviconSize})
      : super(infos: PackageInfosPeek()..screenshots = null, faviconUrl: null);
}
