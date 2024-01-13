import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/output_handling/package_infos/package_infos_full.dart';
import 'package:winget_gui/output_handling/show/compartments/compartment.dart';
import 'package:winget_gui/widget_assets/link_text.dart';
import 'package:winget_gui/widget_assets/right_side_buttons.dart';
import 'package:winget_gui/widget_assets/store_button.dart';
import '../../../widget_assets/decorated_card.dart';
import '../../../widget_assets/favicon_widget.dart';
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
        from(context),
        if (infos.website != null) _website(locale),
        if (infos.category != null) ...[
          LinkText(line: infos.category!.value),
          if (infos.isMicrosoftStore()) _showInStore(locale),
        ],
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

  Widget favicon(double faviconSize) {
    return FaviconWidget(infos: infos, faviconSize: faviconSize);
  }

  double faviconSize() => 70;

  Widget from(BuildContext context) {
    String? author = infos.author?.value;
    String? publisher = infos.agreement?.publisher?.text;
    String? authorOrPublisher = chooseShorterString(author, publisher);
    String text = authorOrPublisher ??
        infos.id?.value.split('.').firstOrNull ??
        '<unknown>';
    return textOrInlineLink(
        context: context, text: text, url: infos.agreement?.publisher?.url);
  }

  String? chooseShorterString(String? a, String? b) {
    if (a == null || b == null) return a ?? b;
    return a.length < b.length ? a : b;
  }
}
