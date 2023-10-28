import 'package:favicon/favicon.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/output_handling/package_infos/package_infos_full.dart';
import 'package:winget_gui/output_handling/show/compartments/compartment.dart';
import 'package:winget_gui/widget_assets/link_text.dart';
import 'package:winget_gui/widget_assets/right_side_buttons.dart';
import 'package:winget_gui/widget_assets/store_button.dart';
import 'package:winget_gui/widget_assets/web_image.dart';

import '../../../widget_assets/decorated_card.dart';
import '../../../widget_assets/link_button.dart';
import '../../package_infos/package_attribute.dart';

class TitleWidget extends Compartment {
  final PackageInfosFull infos;

  const TitleWidget({required this.infos, super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedCard(
      padding: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: buildCompartment(context),
      ),
    );

  }

  @override
  List<Widget> buildCompartment(BuildContext context) {
    return <Widget>[
      AnimatedSize(
        duration: const Duration(milliseconds: 100),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            favicon(faviconSize()),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  nameAndVersion(context),
                  _detailsBelow(context),
                ].withSpaceBetween(height: 10),
              ),
            ),
            if (infos.id != null)
              Padding(
                padding: const EdgeInsets.only(left: 25),
                child: buildRightSide(),
              ),
          ],
        ),
      ),
    ];
  }

  Widget buildRightSide() => RightSideButtons(infos: infos);

  Widget nameAndVersion(BuildContext context) {
    Typography typography = FluentTheme.of(context).typography;
    return RichText(
      text: TextSpan(
          text: '${infos.name?.value ?? '<unknown>'} ',
          style: titleStyle(typography),
          children: [
            if (infos.hasVersion())
              TextSpan(
                text: 'v${infos.version!.value}',
                style: versionStyle(typography),
              )
          ]),
      softWrap: true,
    );
  }

  TextStyle? titleStyle(Typography typography) {
    return typography.titleLarge;
  }

  TextStyle? versionStyle(Typography typography) {
    return typography.title;
  }

  Widget _detailsBelow(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 5,
      runSpacing: 5,
      children: [
        infos.author != null
            ? textOrInlineLink(
                context: context,
                text: infos.author?.value,
                url: infos.agreement?.publisher?.url)
            : infos.agreement?.publisher != null
                ? publisher(context)
                : Text(infos.id?.value ?? '<unknown>'),
        if (infos.website != null) _website(locale),
        if (infos.category != null) ...[
          LinkText(line: infos.category!.value),
          if (infos.isMicrosoftStore()) _showInStore(locale),
        ]
      ].withSpaceBetween(width: 5),
    );
  }

  Widget publisher(BuildContext context) {
    return textOrInlineLink(
        context: context,
        text: infos.agreement?.publisher?.text,
        url: infos.agreement?.publisher?.url);
  }

  Widget _website(AppLocalizations locale) {
    return LinkButton(
        url: infos.website!.value,
        text: Text(PackageAttribute.website.title(locale)));
  }

  StoreButton _showInStore(AppLocalizations locale) {
    return StoreButton(
      storeId: infos.installer!.storeProductID!.value,
    );
  }

  Uri? get faviconUrl =>
      infos.website?.value ?? infos.agreement?.publisher?.url;

  Widget favicon(double faviconSize) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 100),
      child: infos.screenshots?.icon != null &&
              infos.screenshots!.icon.toString().isNotEmpty
          ? loadFavicon(faviconSize, infos.screenshots!.icon.toString())
          : FutureBuilder<Favicon?>(
              future: FaviconFinder.getBest(faviconUrl.toString()),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  Favicon? favicon = snapshot.data;
                  if (favicon != null) {
                    return loadFavicon(faviconSize, favicon.url);
                  }
                }
                return const SizedBox();
              },
            ),
    );
  }

  double faviconSize() => 70;

  Widget loadFavicon(double faviconSize, String url) {
    Widget image;

    image = WebImage(
      url: url,
      imageHeight: faviconSize,
      imageWidth: faviconSize,
      imageConfig: ImageConfig(
        filterQuality: FilterQuality.high,
        isAntiAlias: true,
        errorBuilder: (context, error, stackTrace) {
          return SizedBox(
            width: faviconSize,
            height: faviconSize,
            child: const Icon(FluentIcons.error),
          );
        },
      ),
    );

    return FadeIn(
      duration: const Duration(milliseconds: 500),
      // The green box must be a child of the AnimatedOpacity widget.
      child: Padding(
        padding: const EdgeInsets.only(right: 25),
        child: DecoratedCard(
          padding: 10,
          child: image,
        ),
      ),
    );
  }
}
