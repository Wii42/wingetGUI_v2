import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/output_handling/package_infos/info_with_link.dart';
import 'package:winget_gui/output_handling/package_infos/package_infos_full.dart';
import 'package:winget_gui/output_handling/package_infos/info_extensions.dart';
import 'package:winget_gui/package_sources/package_source.dart';

import '../../../helpers/route_parameter.dart';
import '../../../navigation_pages/search_page.dart';
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
            infos.installer?.fileExtensions?.toStringInfo(),
            infos.installer?.availableCommands?.toStringInfo(),
            infos.installer?.protocols?.toStringInfo(),
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
            if (infos.infosSource != null)
              Info<Uri>(
                title: (locale) => 'Source',
                value: infos.infosSource!,
              ),
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
      return Button(
        child: Text(locale
            .moreFromPublisher(infos.publisherName ?? infos.publisherID!)),
        onPressed: () {
          Navigator.of(context).pushNamed(Routes.publisherPage.route,
              arguments: StringRouteParameter(string: infos.publisherID!));
        },
      );
    }
    if (infos.agreement?.publisher?.text != null &&
        infos.agreement!.publisher!.text!.isNotEmpty) {
      return Button(
        child:
            Text(locale.moreFromPublisher(infos.agreement!.publisher!.text!)),
        onPressed: () =>
            SearchPage.search(context)(infos.agreement!.publisher!.text!),
      );
    }
    return const SizedBox();
  }

  @override
  String compartmentTitle(AppLocalizations locale) {
    return locale.details;
  }
}
