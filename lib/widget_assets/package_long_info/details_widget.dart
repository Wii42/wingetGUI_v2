import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:winget_core/winget_core.dart';
import 'package:winget_gui/helpers/app_localizer.dart';
import 'package:winget_gui/helpers/localized_name.dart';
import 'package:winget_gui/l10n/generated/app_localizations.dart';
import 'package:winget_gui/package_infos/package_infos_extension.dart';
import 'package:winget_gui/package_infos/package_infos_full.dart';

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
          if (infos.publisher?.infoWithLink != null)
            wrapInfoWithLink(context, infos.publisher?.infoWithLink),
          ...detailsList([
            infos.author,
            infos.pricing,
            infos.freeTrial,
            infos.ageRating,
            infos.id?.toStringInfo(),
            if (infos.version?.value.stringValue != 'Unknown')
              infos.version?.toStringInfo(),
            infos.packageLocale?.toStringInfo(
                locale.asLocalizer, LocaleNames.of(context)?.asLocalizedName),
          ], context),
          if (infos.documentation != null)
            wrapInWrap(
              title: infos.documentation!.title(locale.asLocalizer),
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
            infos.installationNotes,
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
      infos.publisher?.id != null ||
      (infos.publisher?.nameFittingId != null &&
          infos.publisher!.nameFittingId!.isNotEmpty);

  @override
  String compartmentTitle(AppLocalizations locale) {
    return locale.details;
  }
}
