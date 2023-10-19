import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:winget_gui/helpers/extensions/string_map_extension.dart';
import 'package:winget_gui/output_handling/package_infos/installer_infos.dart';

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
            infos.locale,
            infos.sha256Hash,
            tryFromDateTimeInfo(infos.releaseDate, locale),
          ], context),
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
    return [
      for (String key in restKeys)
        if (infos.otherInfos!.hasEntry(key))
          wrapInWrap(
            title: key,
            body: textOrLinkButton(
              context: context,
              text: Info<String>(
                value: infos.otherInfos![key]!,
                title: (AppLocalizations _) {
                  return key;
                },
              ),
            ),
          ),
    ];
  }

  List<Widget> _installerDetailsList(
      List<Info<String>?> details, BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return [
      for (Info<String>? string in details)
        if (string != null)
          wrapInWrap(
              title: string.title(locale),
              body: textOrLinkButton(context: context, text: string)),
    ];
  }

  Info<String>? tryFromDateTimeInfo(Info<DateTime>? info, [Locale? locale]) {
    if (info == null) return null;

    String string = DateFormat.yMd(locale.toString()).format(info.value);
    return Info<String>(title: info.title, value: string);
  }
}
