import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/output_handling/package_infos/info_with_link.dart';
import 'package:winget_gui/output_handling/package_infos/package_infos_full.dart';
import 'package:winget_gui/output_handling/package_infos/info_extensions.dart';
import 'package:winget_gui/package_sources/package_source.dart';

import '../../../helpers/route_parameter.dart';
import '../../../routes.dart';
import '../../../widget_assets/buttons/page_button.dart';
import '../../../widget_assets/buttons/search_button.dart';
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
          otherButtons: [
            if (showMoreFromPublisherButton()) moreFromPublisher(context),
          ],
        ),
        context: context);
  }

  bool showMoreFromPublisherButton() =>
      infos.publisherID != null ||
      (infos.agreement?.publisher?.text != null &&
          infos.agreement!.publisher!.text!.isNotEmpty);

  Widget moreFromPublisher(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    if (infos.publisherID != null) {
      return PageButton(
        pageRoute: Routes.publisherPage,
        routeParameter: StringRouteParameter(string: infos.publisherID!),
        buttonText:
            locale.moreFromPublisher(infos.publisherName ?? infos.publisherID!),
        tooltipMessage: 'Show all Apps from this Publisher',
      );
    }
    if (infos.agreement?.publisher?.text != null &&
        infos.agreement!.publisher!.text!.isNotEmpty) {
      return SearchButton(
        searchTarget: infos.agreement!.publisher!.text!,
        customButtonText:
            locale.moreFromPublisher(infos.agreement!.publisher!.text!),
        localization: locale,
      );
    }
    return const SizedBox();
  }

  @override
  String compartmentTitle(AppLocalizations locale) {
    return locale.details;
  }
}
