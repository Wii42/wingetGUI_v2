import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/helpers/extensions/string_map_extension.dart';
import 'package:winget_gui/output_handling/package_infos/info_with_link.dart';
import 'package:winget_gui/output_handling/package_infos/package_infos_full.dart';

import '../../../helpers/route_parameter.dart';
import '../../../routes.dart';
import '../../package_infos/info.dart';
import 'expander_compartment.dart';

class DetailsWidget extends ExpanderCompartment {
  final PackageInfosFull infos;

  @override
  final IconData titleIcon = FluentIcons.info;

  const DetailsWidget({super.key, required this.infos});

  @override
  List<Widget> buildCompartment(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return fullCompartment(
        title: compartmentTitle(locale),
        mainColumn: [
          ...detailsList([
            infos.author,
            infos.agreement?.publisher?.tryToInfoString(),
            infos.pricing,
            infos.freeTrial,
            infos.ageRating,
            infos.id,
            tryFromLocaleInfo(infos.packageLocale, context),
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
          ...detailsList([
            tryFromListInfo(infos.installer?.fileExtensions),
            tryFromListInfo(infos.installer?.availableCommands),
            tryFromListInfo(infos.installer?.protocols),
          ], context),
          ..._displayRest(context)
        ],
        buttonRow: buttonRow(
          [
            infos.supportUrl,
            infos.manifest,
          ],
          context,
          otherButtons: [
            if (infos.publisherID != null)
              Button(
                child: Text(locale.moreFromPublisher(infos.publisherID!)),
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.publisherPage.route,
                      arguments:
                          StringRouteParameter(string: infos.publisherID!));
                },
              )
          ],
        ),
        context: context);
  }

  @override
  String compartmentTitle(AppLocalizations locale) {
    return locale.details;
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
