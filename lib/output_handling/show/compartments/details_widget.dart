import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/helpers/extensions/string_map_extension.dart';
import 'package:winget_gui/output_handling/package_infos/info_with_link.dart';
import 'package:winget_gui/output_handling/package_infos/package_attribute.dart';
import 'package:winget_gui/output_handling/package_infos/package_infos_full.dart';

import '../../../helpers/extensions/string_extension.dart';
import '../../package_infos/info.dart';
import 'compartment.dart';

class DetailsWidget extends Compartment {
  final PackageInfosFull infos;

  const DetailsWidget({super.key, required this.infos});

  @override
  List<Widget> buildCompartment(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return fullCompartment(
        title: compartmentTitle(locale),
        mainColumn: [
          ..._detailsList([
            if (infos.author != null)
              infos.agreement?.publisher?.tryToInfoString(),
            infos.pricing,
            infos.freeTrial,
            infos.ageRating,
            infos.id,
            tryFromLocaleInfo(infos.packageLocale),
          ], context),
          if (infos.documentation != null)
            wrapInWrap(
              title: infos.documentation!.title(locale),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (InfoWithLink doc in infos.documentation!.value)
                    textOrIconLink(
                        context: context, text: doc.text, url: doc.url),
                ],
              ),
            ),
          ..._displayRest(context)
        ],
        buttonRow: buttonRow([
          infos.supportUrl,
          infos.manifest,
        ], context),
        context: context);
  }

  @override
  String compartmentTitle(AppLocalizations locale) {
    return locale.details;
  }

  List<Widget> _detailsList(List<Info<String>?> details, BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return [
      for (Info<String>? info in details)
        if (info != null)
          wrapInWrap(
              title: info.title(locale),

              body: (info.title(locale) == PackageAttribute.id.title(locale))?copyableInfo(info: info, context: context):textOrIconLink(
                  context: context,
                  text: info.value,
                  url: isLink(info.value)
                      ? Uri.tryParse(info.value)
                      : null)),
    ];
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
}
