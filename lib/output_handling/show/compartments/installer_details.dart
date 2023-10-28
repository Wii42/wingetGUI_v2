import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:winget_gui/helpers/extensions/string_map_extension.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/output_handling/package_infos/installer_infos.dart';
import 'package:winget_gui/widget_assets/decorated_card.dart';

import '../../../helpers/extensions/string_extension.dart';
import '../../../widget_assets/app_locale.dart';
import '../../package_infos/info.dart';
import '../../package_infos/package_attribute.dart';
import 'compartment.dart';

class InstallerDetails extends Compartment {
  final InstallerInfos infos;

  const InstallerDetails({super.key, required this.infos});

  @override
  List<Widget> buildCompartment(BuildContext context) {
    AppLocalizations localization = AppLocalizations.of(context)!;
    Locale? locale = AppLocale.of(context).guiLocale;
    return fullCompartment(
        title: compartmentTitle(localization),
        mainColumn: [
          ..._installerDetailsList([
            infos.type,
            infos.storeProductID,
            tryFromLocaleInfo(infos.locale),
            infos.sha256Hash,
            tryFromDateTimeInfo(infos.releaseDate, locale),
            infos.upgradeBehavior,
            tryFromListInfo(infos.fileExtensions),
            tryFromListInfo(infos.platform, toString: (e) => e.title),
            infos.minimumOSVersion,
            infos.scope,
            infos.installModes,
            infos.installerSwitches,
          ], context),
          if (infos.installers != null)
            _displayInstallers(infos.installers!, context),
          ..._displayRest(context),
        ],
        buttonRow: buttonRow([infos.url], context),
        context: context);
  }

  Widget _displayInstallers(Info<List<Installer>> installers, BuildContext context) {
    AppLocalizations localization = AppLocalizations.of(context)!;
    return wrapInWrap(
            title: installers.title(localization),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (Installer installer in installers.value)
                  installerWidget(installer, context),
              ].withSpaceBetween(height: 10),
            ),
          );
  }

  Info<String>? tryFromListInfo<T>(Info<List<T>>? info, {String Function(T)? toString}) {
    if (info == null) return null;
    List<dynamic> list = info.value;
    if(toString != null){
      list = info.value.map((e) => toString(e)).toList();
    }
    String string = list.join(', ');
    return Info<String>(title: info.title, value: string);
  }

  @override
  String compartmentTitle(AppLocalizations locale) {
    return PackageAttribute.installer.title(locale);
  }

  List<Widget> _displayRest(BuildContext context) {
    if (infos.otherInfos == null) {
      return [];
    }
    Iterable<String> restKeys = infos.otherInfos!.keys;
    String value(String key) => infos.otherInfos![key]!;
    return [
      for (String key in restKeys)
        if (infos.otherInfos!.hasEntry(key))
          wrapInWrap(
              title: key,
              body: textOrIconLink(
                  context: context,
                  text: value(key),
                  url: isLink(value(key)) ? Uri.tryParse(value(key)) : null)),
    ];
  }

  List<Widget> _installerDetailsList(
      List<Info<String>?> details, BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return [
      for (Info<String>? info in details)
        if (info != null)
          wrapInWrap(
              title: info.title(locale),
              body: textOrIconLink(
                  context: context,
                  text: info.value,
                  url: isLink(info.value) ? Uri.tryParse(info.value) : null)),
    ];
  }

  Info<String>? tryFromDateTimeInfo(Info<DateTime>? info, [Locale? locale]) {
    if (info == null) return null;

    String string = DateFormat.yMd(locale.toString()).format(info.value);
    return Info<String>(title: info.title, value: string);
  }

  Widget installerWidget(Installer installer, BuildContext context) {
    return DecoratedCard(
      padding: 10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: fullCompartment(
            context: context,
            mainColumn: [
              ..._installerDetailsList([
                installer.architecture,
                installer.sha256Hash,
                installer.signatureSha256,
                tryFromLocaleInfo(installer.locale),
                tryFromListInfo(installer.platform, toString: (e) => e.title),
                installer.minimumOSVersion,
                installer.type,
                installer.scope,
                installer.elevationRequirement,
                installer.productCode,
                installer.appsAndFeaturesEntries,
                installer.switches,
                installer.modes,


              ], context),
              if (installer.other.isNotEmpty) Text(installer.other.toString()),
            ],
            buttonRow: buttonRow([
              installer.url
            ], context)),
      ),
    );
  }
}
