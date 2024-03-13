import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/output_handling/package_infos/info_extensions.dart';
import 'package:winget_gui/output_handling/package_infos/package_infos_full.dart';
import 'package:winget_gui/output_handling/show/compartments/compartment.dart';
import 'package:winget_gui/widget_assets/link_text.dart';
import 'package:winget_gui/widget_assets/right_side_buttons.dart';
import 'package:winget_gui/widget_assets/store_button.dart';
import '../../../widget_assets/decorated_card.dart';
import '../../../widget_assets/favicon_widget.dart';
import '../../../widget_assets/link_button.dart';
import '../../../winget_db/db_message.dart';
import '../../../winget_db/winget_db.dart';
import '../../package_infos/info.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart' as icons;

class TitleWidget extends Compartment {
  final PackageInfosFull infos;

  const TitleWidget({required this.infos, super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedCard(
      padding: 20,
      child: StreamBuilder<DBMessage>(
          stream: WingetDB.instance.installed.stream,
          builder: (context, snapshot) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: buildCompartment(context),
            );
          }),
    );
  }

  @override
  List<Widget> buildCompartment(BuildContext context) {
    return <Widget>[
      Row(
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
    ];
  }

  Widget buildRightSide() => StreamBuilder<DBMessage>(
      stream: WingetDB.instance.installed.stream,
      builder: (context, snapshot) {
        bool isInstalled =
            WingetDB.instance.installed.idMap.containsKey(infos.id?.value);
        bool hasUpdate =
            WingetDB.instance.updates.idMap.containsKey(infos.id?.value);
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
          text: '${infos.name?.value ?? '<unknown>'} ',
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
        from(context),
        if (infos.website != null && infos.website!.isNotEmpty) _website(locale),
        if (infos.category != null) ...[
          LinkText(line: infos.category!.value),
          if (infos.isMicrosoftStore()) _showInStore(locale),
        ],
        if (WingetDB.isPackageInstalled(infos)) installedIcon(context),
      ].withSpaceBetween(width: 5),
    );
  }

  Widget publisher(BuildContext context) {
    return textOrInlineLink(
        context: context,
        text: infos.agreement?.publisher?.text,
        url: infos.agreement?.publisher?.url);
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
        text: Text(website.value.toString().startsWith('https://github.com/')
            ? 'GitHub'
            : website.title(locale)));
  }

  StoreButton _showInStore(AppLocalizations locale) {
    return StoreButton(
      storeId: infos.installer?.storeProductID?.value ??
          infos.installer?.installers?.value.firstOrNull?.storeProductID
              ?.value ??
          '',
    );
  }

  Widget favicon(double faviconSize) {
    return FaviconWidget(infos: infos, faviconSize: faviconSize);
  }

  static double faviconSize() => 70;

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
