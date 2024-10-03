import 'package:fluent_ui/fluent_ui.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart' as icons;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/db/db_message.dart';
import 'package:winget_gui/db/package_tables.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/helpers/route_parameter.dart';
import 'package:winget_gui/package_infos/info.dart';
import 'package:winget_gui/package_infos/info_extensions.dart';
import 'package:winget_gui/package_infos/package_infos_full.dart';
import 'package:winget_gui/package_infos/publisher.dart';
import 'package:winget_gui/routes.dart';
import 'package:winget_gui/widget_assets/app_icon.dart';
import 'package:winget_gui/widget_assets/buttons/link_button.dart';
import 'package:winget_gui/widget_assets/buttons/page_button.dart';
import 'package:winget_gui/widget_assets/buttons/right_side_buttons.dart';
import 'package:winget_gui/widget_assets/buttons/search_button.dart';
import 'package:winget_gui/widget_assets/buttons/store_button.dart';
import 'package:winget_gui/widget_assets/decorated_card.dart';
import 'package:winget_gui/widget_assets/link_text.dart';

import 'compartment.dart';

class TitleWidget extends Compartment {
  final PackageInfosFull infos;

  const TitleWidget({required this.infos, super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedCard(
      padding: 20,
      child: LayoutBuilder(builder: (context, constraints) {
        return StreamBuilder<DBMessage>(
            stream: PackageTables.instance.installed.stream,
            builder: (context, snapshot) {
              double width = constraints.maxWidth;
              bool isWide = width > 420;
              return isWide
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: titleParts(context, isWide),
                    )
                  : Column(
                      //crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: titleParts(context, isWide),
                    );
            });
      }),
    );
  }

  @override
  List<Widget> buildCompartment(BuildContext context) =>
      titleParts(context, true);

  List<Widget> titleParts(BuildContext context, bool isWide) {
    Widget nameAndCenter = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        nameAndVersion(context),
        _detailsBelow(context),
      ].withSpaceBetween(height: 10, width: 10),
    );
    return [
      favicon(faviconSize()),
      if (isWide) Expanded(child: nameAndCenter) else nameAndCenter,
      if (infos.id != null)
        Padding(
          padding: isWide
              ? const EdgeInsets.only(left: 25)
              : const EdgeInsets.only(top: 10),
          child: buildRightSide(),
        ),
    ];
  }

  Widget buildRightSide() => StreamBuilder<DBMessage>(
      stream: PackageTables.instance.installed.stream,
      builder: (context, snapshot) {
        bool isInstalled =
            PackageTables.instance.installed.idMap.containsKey(infos.id?.value);
        bool hasUpdate =
            PackageTables.instance.updates.idMap.containsKey(infos.id?.value);
        return RightSideButtons(
          infos: infos,
          install: !isInstalled,
          uninstall: isInstalled,
          upgrade: hasUpdate,
          showUnselectedOptionsAsDisabled: true,
        );
      });

  Widget nameAndVersion(BuildContext context) {
    Typography typography = FluentTheme.of(context).typography;
    return RichText(
      text: TextSpan(
          text:
              '${infos.name?.value ?? infos.id?.value.idPartsAsName ?? '<unknown>'} ',
          style: titleStyle(typography),
          children: [
            if (infos.hasVersion())
              TextSpan(
                text: infos.displayVersion(),
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
        publisher(context),
        if (infos.website != null && infos.website!.isNotEmpty)
          _website(locale),
        if (infos.category != null) ...[
          LinkText(line: infos.category!.value),
          if (infos.isMicrosoftStore()) _showInStore(locale),
        ],
        if (PackageTables.isPackageInstalled(infos)) installedIcon(context),
      ].withSpaceBetween(width: 5),
    );
  }

  Widget installedIcon(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          icons.FluentIcons.checkmark_circle_20_regular,
        ),
        const SizedBox(width: 5),
        Text(AppLocalizations.of(context)!.installed),
      ],
    );
  }

  Widget _website(AppLocalizations locale) {
    if (infos.website == null) return const SizedBox();
    Info<Uri> website = infos.website!;
    return LinkButton(
        url: website.value,
        buttonText: website.value.toString().startsWith('https://github.com/')
            ? 'GitHub'
            : website.title(locale));
  }

  StoreButton _showInStore(AppLocalizations locale) {
    return StoreButton(
      storeId: infos.installer?.value.firstOrNull?.storeProductID?.value ?? '',
      locale: locale,
    );
  }

  Widget favicon(double faviconSize) {
    return AppIcon.fromInfos(infos, iconSize: faviconSize);
  }

  static double faviconSize() => 70;

  Widget publisher(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    Publisher? publisher = infos.publisher;
    String? publisherId = publisher?.id;
    String? publisherName =
        publisher?.nameFittingId ?? publisherId ?? formattedPublisherUrl();
    if (publisherId != null) {
      return InlinePageButton(
        pageRoute: Routes.publisherPage,
        routeParameter: StringRouteParameter(string: publisherId),
        buttonText: publisherName!,
        tooltipMessage: (locale) => locale.moreFromPublisherTooltip,
      );
    }
    if (publisherName != null && publisherName.isNotEmpty) {
      return InlineSearchButton(
        searchTarget: publisherName,
        customButtonText: publisherName,
        localization: locale,
      );
    }
    return Text(
      infos.author?.value ??
          infos.id?.value.probablyPublisherId() ??
          '<Unknown Publisher>',
    );
  }

  String? formattedPublisherUrl() {
    return infos.publisher?.website?.host;
  }
}
