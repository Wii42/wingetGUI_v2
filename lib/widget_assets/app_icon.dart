import 'dart:collection';

import 'package:favicon/favicon.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/helpers/package_screenshots.dart';
import 'package:winget_gui/widget_assets/web_image.dart';

import '../helpers/log_stream.dart';
import '../output_handling/package_infos/package_infos.dart';
import '../output_handling/package_infos/package_infos_full.dart';
import '../package_sources/package_source.dart';
import 'decorated_card.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart' as icons;

import 'favicon_db.dart';

class AppIcon extends StatefulWidget {
  late final Logger log;
  final double iconSize;

  /// The URL of which a favicon can be found, not the URL of the image itself.
  late final Uri? faviconUrl;
  final bool isClickable;

  /// The URLs of the images. The first non Null  which throws no error will be used.
  final List<Uri?> iconUrls;

  /// The URLs of the images to use if the main ones fail.
  /// Icon is greyed out, should be used for e.g. the publisher icon.
  final List<Uri?> fallbackIconUrls;
  final bool withRightSidePadding;
  final PackageSources packageSource;
  final String? packageId;
  final List<Uri> automaticFoundFavicons;

  AppIcon({
    super.key,
    required this.iconSize,
    this.isClickable = true,
    this.faviconUrl,
    this.iconUrls = const [],
    this.fallbackIconUrls = const [],
    this.withRightSidePadding = true,
    this.packageSource = PackageSources.none,
    this.packageId,
    this.automaticFoundFavicons = const [],
  }) {
    log = Logger(this);
  }

  factory AppIcon.fromInfos(
    PackageInfos infos, {
    required double iconSize,
    bool withRightSidePadding = true,
    bool isClickable = true,
  }) {
    PackageScreenshots? images = infos.screenshots;
    PackageInfosFull? infosFull;
    if (infos is PackageInfosFull) {
      infosFull = infos;
    }
    return AppIcon(
      iconSize: iconSize,
      iconUrls: [images?.icon, images?.icon, images?.backup?.icon],
      faviconUrl:
          infosFull?.website?.value ?? infosFull?.agreement?.publisher?.url,
      fallbackIconUrls: [infos.publisherIcon],
      packageSource: infos.source.value,
      withRightSidePadding: withRightSidePadding,
      isClickable: isClickable,
      packageId: infos.id?.value,
      automaticFoundFavicons: [
        if (infos.automaticFoundFavicons != null) infos.automaticFoundFavicons!
      ],
    );
  }

  @override
  State<AppIcon> createState() => _AppIconState();
}

class _AppIconState extends State<AppIcon> {
  List<Uri> automaticFoundFavicons = [];
  @override
  void initState() {
    automaticFoundFavicons = widget.automaticFoundFavicons;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.withRightSidePadding
          ? const EdgeInsets.only(right: 25)
          : EdgeInsets.zero,
      child: DecoratedCard(
        padding: 0.17 * widget.iconSize,
        child: SizedBox(
          width: widget.iconSize,
          height: widget.iconSize,
          child: Center(child: appIcon()),
        ),
      ),
    );
  }

  Widget appIcon() {
    Queue urlQueue = Queue.from(getPossibleUrls());
    return loadIconFromQueue(urlQueue);
  }

  Widget loadIconFromQueue(Queue urlQueue) {
    if (urlQueue.isEmpty) {
      return fallbackFavicon();
    }
    UrlColor urlColor = urlQueue.removeFirst();
    return loadFavicon(
      urlColor.url.toString(),
      size: widget.iconSize,
      onError: () => loadIconFromQueue(urlQueue),
      color: urlColor.color,
    );
  }

  Widget fallbackFavicon() {
    if (widget.faviconUrl != null) {
      return findFavicon();
    }
    return defaultIcon();
  }

  Uri? faviconUrlFromDB() {
    if (widget.packageId == null) {
      return null;
    }
    return FaviconDB.instance.getFavicon(widget.packageId!);
  }

  Widget findFavicon() {
    return FutureBuilder<Favicon?>(
      future: FaviconGetter.getFavicon(widget.faviconUrl,
          packageId: widget.packageId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Favicon? favicon = snapshot.data;
          if (favicon != null) {
            automaticFoundFavicons.add(Uri.parse(favicon.url));
            widget.log.info(favicon.url);
            return loadFavicon(favicon.url,
                size: widget.iconSize, onError: () => defaultIcon());
          }
        }
        return defaultIcon();
      },
    );
  }

  Widget defaultIcon() {
    IconData icon = FluentIcons.product;
    if (widget.packageSource == PackageSources.microsoftStore) {
      icon = icons.FluentIcons.store_microsoft_20_regular;
    }
    return Icon(
      icon,
      size: widget.iconSize,
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
        filterQuality: FilterQuality.none,
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
    Iterable<UrlColor> urls = [
      ...asUrlColors(widget.iconUrls),
      ...asUrlColors(widget.fallbackIconUrls, color: defaultColor()),
      ...asUrlColors(automaticFoundFavicons),
      ...asUrlColors([faviconUrlFromDB()]),
    ];
    return urls;
  }

  Iterable<UrlColor> asUrlColors(Iterable<Uri?> urls, {Color? color}) {
    Iterable<Uri> goodUrls = urls
        .where((element) =>
            element != null && element.toString().trim().isNotEmpty)
        .cast<Uri>();
    return goodUrls.map((e) => UrlColor(url: e, color: color));
  }
}

class DefaultFavicon extends AppIcon {
  DefaultFavicon(
      {super.key, required super.iconSize, super.isClickable = true});
}

class UrlColor {
  Uri url;
  Color? color;

  UrlColor({required this.url, this.color});
}

class FaviconGetter {
  static const Map<String, String> codeHosts = {
    'github.com': 'https://github.githubassets.com/favicons/favicon.svg',
    'sourceforge.net':
        'https://a.fsdn.com/con/img/sandiego/svg/originals/sf-icon-orange-no_sf.svg',
    'bitbucket.org':
        'https://d301sr5gafysq2.cloudfront.net/3c154c6a443d/img/logos/bitbucket/android-chrome-192x192.png',
  };

  static Future<Favicon?> getFavicon(Uri? url, {String? packageId}) async {
    if (url == null) {
      return null;
    }
    Favicon? favicon = await FaviconFinder.getBest(url.toString());
    if (favicon == null || isFaviconOfCodeHost(favicon.url)) {
      return null;
    }
    if (packageId != null) {
      FaviconDB.instance.insertFavicon(
          FaviconDBEntry(packageId: packageId, url: Uri.parse(favicon.url)));
    }
    return favicon;
  }

  static bool isFaviconOfCodeHost(String faviconUrl) {
    return codeHosts.values.contains(faviconUrl);
  }
}
