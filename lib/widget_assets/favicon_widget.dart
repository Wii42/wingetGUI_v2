import 'dart:collection';

import 'package:favicon/favicon.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/helpers/package_screenshots.dart';
import 'package:winget_gui/output_handling/package_infos/package_infos_peek.dart';
import 'package:winget_gui/widget_assets/web_image.dart';

import '../helpers/log_stream.dart';
import '../output_handling/package_infos/package_infos.dart';
import '../output_handling/package_infos/package_infos_full.dart';
import 'decorated_card.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart' as icons;

const Map<String, String> codeHosts = {
  'github.com': 'https://github.githubassets.com/favicons/favicon.svg',
  'sourceforge.net':
      'https://a.fsdn.com/con/img/sandiego/svg/originals/sf-icon-orange-no_sf.svg',
  'bitbucket.org':
      'https://d301sr5gafysq2.cloudfront.net/3c154c6a443d/img/logos/bitbucket/android-chrome-192x192.png',
};

class FaviconWidget extends StatefulWidget {
  late final Logger log;
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
    log = Logger(this);
    if (faviconUrl != null) {
      this.faviconUrl = faviconUrl;
      return;
    }
    if (infos is PackageInfosFull) {
      PackageInfosFull infosFull = infos as PackageInfosFull;
      this.faviconUrl =
          infosFull.website?.value ?? infosFull.agreement?.publisher?.url;
      return;
    }
    this.faviconUrl = null;
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
      padding: widget.withRightSiePadding
          ? const EdgeInsets.only(right: 25)
          : EdgeInsets.zero,
      child: DecoratedCard(
        padding: 0.17 * widget.faviconSize,
        child: SizedBox(
          width: widget.faviconSize,
          height: widget.faviconSize,
          child: Center(child: favicon()),
        ),
      ),
    );
  }

  Widget favicon() {
    Queue urlQueue = Queue.from(getPossibleUrls());
    return loadFaviconFromQueue(urlQueue);
  }

  Widget loadFaviconFromQueue(Queue urlQueue) {
    if (urlQueue.isEmpty) {
      return fallbackFavicon();
    }
    UrlColor urlColor = urlQueue.removeFirst();
    return loadFavicon(
      urlColor.url.toString(),
      size: widget.faviconSize,
      onError: () => loadFaviconFromQueue(urlQueue),
      color: urlColor.color,
    );
  }

  Widget fallbackFavicon() {
    if (widget.faviconUrl != null) {
      return findFavicon();
    }
    return defaultFavicon();
  }

  Widget findFavicon() {
    return FutureBuilder<Favicon?>(
      future: FaviconFinder.getBest(widget.faviconUrl.toString()),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Favicon? favicon = snapshot.data;
          if (favicon != null && !isFaviconOfCodeHost(favicon.url)) {
            widget.log.info(favicon.url);
            return loadFavicon(favicon.url,
                size: widget.faviconSize, onError: () => defaultFavicon());
          }
        }
        return defaultFavicon();
      },
    );
  }

  Widget defaultFavicon() {
    IconData icon = FluentIcons.product;
    if (widget.infos.isMicrosoftStore()) {
      icon = icons.FluentIcons.store_microsoft_20_regular;
    }
    return Icon(
      icon,
      size: widget.faviconSize,
      color: defaultColor(),
    );
  }

  Color? defaultColor() {
    return FluentTheme.of(context)
        .inactiveColor
        .withAlpha(widget.isClickable ? 100 : 50);
  }

  Widget loadFavicon(String url,
      {required double size,
      required Widget Function() onError,
      Color? color}) {
    Widget image;

    image = WebImage(
      url: url,
      imageHeight: size,
      imageWidth: size,
      isHalfTransparent: !widget.isClickable,
      imageConfig: ImageConfig(
        filterQuality: FilterQuality.high,
        isAntiAlias: true,
        errorBuilder: (context, error, stackTrace) {
          return onError();
        },
        solidColor: color,
      ),
    );
    return image;
  }

  Iterable<UrlColor> getPossibleUrls() {
    PackageScreenshots? images = widget.infos.screenshots;
    Iterable<_TempUrlColor> urls = [
      _TempUrlColor(url: widget.iconUrl),
      _TempUrlColor(url: images?.icon),
      _TempUrlColor(url: images?.backup?.icon),
      _TempUrlColor(url: widget.infos.publisherIcon, color: defaultColor()),
    ];
    urls = urls.where((element) => element.url != null);
    Iterable<UrlColor> urlColors =
        urls.map((e) => UrlColor(url: e.url!, color: e.color));
    return urlColors
        .where((UrlColor element) => element.url.toString().isNotEmpty);
  }

  bool isFaviconOfCodeHost(String faviconUrl) {
    return codeHosts.values.contains(faviconUrl);
  }
}

class DefaultFavicon extends FaviconWidget {
  DefaultFavicon(
      {super.key, required super.faviconSize, super.isClickable = true})
      : super(infos: PackageInfosPeek()..screenshots = null);
}

class _TempUrlColor {
  Uri? url;
  Color? color;

  _TempUrlColor({required this.url, this.color});
}

class UrlColor {
  Uri url;
  Color? color;

  UrlColor({required this.url, this.color});
}
