import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/helpers/extensions/string_map_extension.dart';
import 'package:winget_gui/output_handling/show/package_long_info.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../info_enum.dart';
import 'compartment.dart';

class DetailsWidget extends Compartment {
  const DetailsWidget({super.key, required super.infos});

  static final List<Info> manuallyHandledKeys = [
    Info.author,
    Info.id,
    Info.publisherSupportUrl,
    Info.documentation,
    Info.agreement,
    Info.pricing,
    Info.freeTrial,
    Info.ageRating,
  ];

  final String title = 'Details';

  @override
  List<Widget> buildCompartment(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return fullCompartment(
        title: title,
        mainColumn: [
          ..._detailsList([
            if (infos.details.hasInfo(Info.author, locale)) Info.publisher,
            Info.agreement,
            Info.pricing,
            Info.freeTrial,
            Info.ageRating,
            Info.id,
            Info.documentation,
          ], context),
          ..._displayRest(context)
        ],
        buttonRow: buttonRow([Info.publisherSupportUrl], context),
        context: context);
  }

  List<Widget> _detailsList(List<Info> details, BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return [
      for (Info info in details)
        if (infos.details.hasInfo(info, locale))
          wrapInWrap(
              title: info.title,
              body: textOrLinkButton(context: context, key: info.key(locale))),
    ];
  }

  List<Widget> _displayRest(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    List<String> restKeys = [];
    for (String key in infos.details.keys) {
      if (!PackageLongInfo.isManuallyHandled(key, locale)) {
        restKeys.add(key);
      }
    }
    return [
      for (String key in restKeys)
        if (infos.details.hasEntry(key))
          wrapInWrap(
              title: key, body: textOrLinkButton(context: context, key: key)),
    ];
  }

  static Iterable<String> manuallyHandledStringKeys(AppLocalizations locale) =>
      manuallyHandledKeys.map<String>((Info info) => info.key(locale));

  static bool containsData(Map<String, String> infos, AppLocalizations locale) {
    for (String key in manuallyHandledStringKeys(locale)) {
      if (infos.hasEntry(key) ||
          !PackageLongInfo.isManuallyHandled(key, locale)) {
        return true;
      }
    }
    return false;
  }
}
