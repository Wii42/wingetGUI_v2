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
          ], context),
          if (infos.fileExtensions != null)
            wrapInWrap(
              title: infos.fileExtensions!.title(localization),
              body: Text(infos.fileExtensions!.value.join(', ')),
            ),
          if (infos.installers != null)
            wrapInWrap(
              title: infos.installers!.title(localization),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (Installer installer in infos.installers!.value)
                    installerWidget(installer, context),
                ].withSpaceBetween(height: 10),
              ),
            ),
          if (infos.platform != null)
            wrapInWrap(
              title: infos.platform!.title(localization),
              body: Text(
                  infos.platform!.value.map<String>((e) => e.title).join(', ')),
            ),
          ..._displayRest(context),
        ],
        buttonRow: buttonRow([infos.url], context),
        context: context);
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
        children:
          fullCompartment(context: context, mainColumn:[
          wrapInWrap(title: 'Architecture', body: Text(installer.architecture)),
          wrapInWrap(title: 'SHA256', body: copyableInfo(info: Info<String>(title: (_) => installer.sha256Hash, value: installer.sha256Hash), context: context)),
          if (installer.hashSignature != null) Text(installer.hashSignature!),
          if (installer.locale != null) Text(installer.locale!.toLanguageTag()),
          if (installer.platform != null) Text(installer.platform!.join(', ')),
          if (installer.minimumOSVersion != null)
            Text(installer.minimumOSVersion!),
          if (installer.type != null) Text(installer.type!),
          if (installer.scope != null) Text(installer.scope!),
          if (installer.elevationRequirement != null)
            Text(installer.elevationRequirement!),
          if (installer.productCode != null) Text(installer.productCode!),
          if (installer.appsAndFeaturesEntries != null)
            Text(installer.appsAndFeaturesEntries!),
          if (installer.switches != null) Text(installer.switches!),
          if (installer.modes != null) Text(installer.modes!),
          if (installer.other.isNotEmpty) Text(installer.other.toString()),
        ],
            buttonRow: buttonRow([Info<Uri>(title: PackageAttribute.installerURL.title, value: installer.url)], context)
          ),
      ),
    );
  }
}
