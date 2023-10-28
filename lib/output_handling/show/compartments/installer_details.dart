import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:winget_gui/helpers/extensions/string_map_extension.dart';
import 'package:winget_gui/output_handling/package_infos/installer_infos.dart';

import '../../../helpers/extensions/string_extension.dart';
import '../../../widget_assets/app_locale.dart';
import '../../package_infos/info.dart';
import '../../package_infos/package_attribute.dart';
import 'expander_compartment.dart';

class InstallerDetails extends ExpanderCompartment {
  final InstallerInfos infos;

  const InstallerDetails({super.key, required this.infos});

  @override
  List<Widget> buildCompartment(BuildContext context) {
    AppLocalizations localization = AppLocalizations.of(context)!;
    Locale? locale = AppLocale.of(context).guiLocale;
    return fullCompartment(
        title: compartmentTitle(localization),
        mainColumn: [
          ...detailsList([
            infos.type,
            infos.storeProductID,
            tryFromLocaleInfo(infos.locale, context),
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
          ..._displayRest(context),
        ],
        buttonRow: infos.url != null
            ? buttonRow([infos.url], context)
            : (infos.installers != null)
                ? _displayInstallers(infos.installers!, context)
                : null,
        context: context);
  }

  @override
  bool get initiallyExpanded => false;

  Wrap _displayInstallers(
      Info<List<Installer>> installers, BuildContext context) {
    return Wrap(
        spacing: 5,
        runSpacing: 5,
        children: [
          for (Installer installer in installers.value)
            installerWidget(installer, installers.value, context),
        ],

    );
  }

  Info<String>? tryFromListInfo<T>(Info<List<T>>? info,
      {String Function(T)? toString}) {
    if (info == null) return null;
    List<dynamic> list = info.value;
    if (toString != null) {
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

  Info<String>? tryFromDateTimeInfo(Info<DateTime>? info, [Locale? locale]) {
    if (info == null) return null;

    String string = DateFormat.yMd(locale.toString()).format(info.value);
    return Info<String>(title: info.title, value: string);
  }

  Widget installerWidget(Installer installer, List<Installer> installerList,
      BuildContext context) {
    return Expander(
      header: Text(
        installerPreview(installer, installerList),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: fullCompartment(
            context: context,
            mainColumn: [
              ...detailsList([
                installer.architecture,
                installer.sha256Hash,
                installer.signatureSha256,
                tryFromLocaleInfo(installer.locale, context),
                tryFromListInfo(installer.platform, toString: (e) => e.title),
                installer.minimumOSVersion,
                installer.type,
                installer.scope,
                installer.elevationRequirement,
                installer.productCode,
                //installer.appsAndFeaturesEntries,
                installer.switches,
                installer.modes,
              ], context),
              if (installer.other.isNotEmpty) Text(installer.other.toString()),
            ],
            buttonRow: buttonRow([installer.url], context)),
      ),
    );
  }

  String installerPreview(Installer installer, List<Installer> installerList) {
    String base = installer.architecture.value;
    List<String> preview = [base];
    if (installerList.length >= 2) {
      if (!installerList.isFeatureEverywhereTheSame((e) => e.type)) {
        if (installer.type != null) {
          preview.add(installer.type!.value);
        }
      }
      if (!installerList.isFeatureEverywhereTheSame((e) => e.locale)) {
        if (installer.locale != null) {
          preview.add(installer.locale!.value.toLanguageTag());
        }
      }
      if (!installerList.isFeatureEverywhereTheSame((e) => e.scope)) {
        if (installer.scope != null) {
          preview.add(installer.scope!.value);
        }
      }
    }
    preview.add('Installer');
    return preview.join(' ');
  }
}
