import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/output_handling/show/compartments/details_widget.dart';
import 'package:winget_gui/output_handling/show/compartments/expandable_text_compartment.dart';
import 'package:winget_gui/output_handling/show/compartments/installer_details.dart';
import 'package:winget_gui/output_handling/show/compartments/screenshots_widget.dart';
import 'package:winget_gui/output_handling/show/compartments/title_widget.dart';
import 'package:winget_gui/widget_assets/search_button.dart';

import '../package_infos/package_infos_full.dart';
import 'compartments/agreement_widget.dart';

class PackageLongInfo extends StatelessWidget {
  final PackageInfosFull infos;

  const PackageLongInfo(this.infos, {super.key});

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print(infos.screenshots);
    }
    return Column(
      children: [
        TitleWidget(infos: infos),
        if (infos.screenshots?.screenshots != null &&
            infos.screenshots!.screenshots!.isNotEmpty)
          ScreenshotsWidget(infos.screenshots!),
        if (infos.hasDescription())
          ExpandableTextCompartment(
            text: infos.additionalDescription ??
                infos.description ??
                infos.shortDescription!,
            title: (infos.description != null &&
                    infos.additionalDescription != null)
                ? infos.shortDescription
                : null,
            titleIcon: FluentIcons.edit,
          ),
        if (infos.hasReleaseNotes())
          ExpandableTextCompartment(
            text: infos.releaseNotes!.toInfoString(),
            buttonInfos: [infos.releaseNotes?.tryToInfoUri()],
            titleIcon: FluentIcons.product_release,
          ),
        DetailsWidget(infos: infos),
        if (infos.agreement != null) AgreementWidget(infos: infos.agreement!),
        if (infos.installer != null) InstallerDetails(infos: infos.installer!),
        if (infos.hasTags()) _tagButtons(context),
      ].withSpaceBetween(height: 10),
    );
  }

  Widget _tagButtons(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return Wrap(
      runSpacing: 5,
      spacing: 5,
      alignment: WrapAlignment.center,
      children: [
        if (infos.moniker != null)
          SearchButton(
            searchTarget: infos.moniker!.value,
            localization: locale,
          ),
        for (String tag in infos.tags!)
          SearchButton(
            searchTarget: tag,
            localization: locale,
          )
      ],
    );
  }
}
