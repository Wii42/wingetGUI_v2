import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/output_handling/package_infos/info_with_link.dart';
import 'package:winget_gui/output_handling/package_infos/package_infos_full.dart';
import 'package:winget_gui/output_handling/package_infos/info_extensions.dart';
import 'package:winget_gui/package_sources/package_source.dart';

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
          if (infos.agreement?.publisher != null)
            wrapInfoWithLink(context, infos.agreement?.publisher),
          ...detailsList([
            infos.author,
            infos.pricing,
            infos.freeTrial,
            infos.ageRating,
            infos.id,
            if (infos.version?.value.stringValue != 'Unknown')
              infos.version?.toStringInfo(),
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
            infos.installer?.value.firstOrNull?.fileExtensions?.toStringInfo(),
            infos.installer?.value.firstOrNull?.availableCommands
                ?.toStringInfo(),
            infos.installer?.value.firstOrNull?.protocols?.toStringInfo(),
            infos.source.value != PackageSources.none
                ? infos.source.toStringInfo()
                : null,
          ], context),
          ...displayRest(infos.otherInfos, context),
        ],
        buttonRow: buttonRow(
          [
            infos.supportUrl,
            infos.manifest,
          ],
          context,
        ),
        context: context);
  }

  bool showMoreFromPublisherButton() =>
      infos.publisherID != null ||
      (infos.agreement?.publisher?.text != null &&
          infos.agreement!.publisher!.text!.isNotEmpty);

  @override
  String compartmentTitle(AppLocalizations locale) {
    return locale.details;
  }
}
