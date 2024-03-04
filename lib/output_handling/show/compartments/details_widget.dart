import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/output_handling/package_infos/info_with_link.dart';
import 'package:winget_gui/output_handling/package_infos/package_infos_full.dart';
import 'package:winget_gui/output_handling/package_infos/to_string_info_extensions.dart';

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
            infos.agreement?.publisher?.toStringInfo(),
            infos.pricing,
            infos.freeTrial,
            infos.ageRating,
            infos.id,
            if (infos.version?.value != 'Unknown') infos.version,
            infos.packageLocale?.toStringInfo(context),
          ], context),
          if (infos.documentation != null)
            wrapInWrap(
              title: infos.documentation!.title(locale),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (InfoWithLink doc in infos.documentation!.value)
                    fromInfoWithLink(context, doc),
                ],
              ),
            ),
          ...detailsList([
            infos.installer?.fileExtensions?.toStringInfo(),
            infos.installer?.availableCommands?.toStringInfo(),
            infos.installer?.protocols?.toStringInfo(),
          ], context),
          ...displayRest(infos.otherInfos, context),
        ],
        buttonRow: buttonRow(
          [
            infos.supportUrl,
            infos.manifest,
            if(infos.infosSource != null)
              Info<Uri>(
                title: (locale)=>'Source',
                value: infos.infosSource!,
              ),
          ],
          context,
          otherButtons: [
            if (infos.publisherID != null)
              Button(
                child: Text(locale.moreFromPublisher(
                    infos.publisherName ?? infos.publisherID!)),
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
}
