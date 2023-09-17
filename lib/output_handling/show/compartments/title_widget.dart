import 'package:favicon/favicon.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:flutter_svg/svg.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/output_handling/infos/package_infos_full.dart';
import 'package:winget_gui/output_handling/show/compartments/compartment.dart';
import 'package:winget_gui/widget_assets/link_text.dart';
import 'package:winget_gui/widget_assets/right_side_buttons.dart';
import 'package:winget_gui/widget_assets/store_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../widget_assets/decorated_card.dart';
import '../../../widget_assets/link_button.dart';
import '../../infos/package_attribute.dart';

class TitleWidget extends Compartment {
  final PackageInfosFull infos;

  const TitleWidget({required this.infos, super.key});

  @override
  List<Widget> buildCompartment(BuildContext context) {
    return <Widget>[
      AnimatedSize(
        duration: const Duration(milliseconds: 100),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            favicon(),
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
                child: RightSideButtons(infos: infos),
              ),
          ],
        ),
      ),
    ];
  }

  @override
  String compartmentTitle(AppLocalizations locale) {
    return PackageAttribute.name.title(locale);
  }

  Widget nameAndVersion(BuildContext context) {
    return RichText(
      text: TextSpan(
          text: '${infos.name?.value ?? '<unknown>'} ',
          style: FluentTheme.of(context).typography.titleLarge,
          children: [
            if (infos.hasVersion())
              TextSpan(
                text: 'v${infos.version!.value}',
                style: FluentTheme.of(context).typography.title,
              )
          ]),
      softWrap: true,
    );
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
          if (infos.installer?.type?.value.trim() == 'msstore' &&
              infos.installer?.storeProductID != null)
            _showInStore(locale),
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

  Widget favicon() {
    double size = 70;

    return AnimatedSize(
      duration: const Duration(milliseconds: 100),
      child: FutureBuilder<Favicon?>(
        future: FaviconFinder.getBest(faviconUrl.toString()),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Favicon? favicon = snapshot.data;
            if (favicon != null) {
              String imageType =
                  favicon.url.substring(favicon.url.lastIndexOf('.') + 1);
              Widget image;

              if (imageType == 'svg') {
                image = SvgPicture.network(
                  favicon.url,
                  width: size,
                  height: size,
                );
              } else {
                image = Image.network(
                  favicon.url,
                  width: size,
                  height: size,
                  filterQuality: FilterQuality.high,
                  isAntiAlias: true,
                  //fit: BoxFit.contain,
                );
              }

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
          return const SizedBox();
        },
      ),
    );
  }
}
