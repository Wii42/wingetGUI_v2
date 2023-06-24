import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/helpers/extensions/string_map_extension.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/output_handling/show/compartments/agreement_widget.dart';
import 'package:winget_gui/output_handling/show/compartments/details_widget.dart';
import 'package:winget_gui/output_handling/show/compartments/expandable_compartment.dart';
import 'package:winget_gui/output_handling/show/compartments/installer_details.dart';
import 'package:winget_gui/output_handling/show/compartments/title_widget.dart';
import 'package:winget_gui/widget_assets/search_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../info_enum.dart';
import '../infos.dart';

class PackageLongInfo extends StatelessWidget {
  static final List<Info> manuallyHandledKeys = [
    Info.description,
    Info.tags,
    Info.releaseNotes,
    Info.installer,
    Info.releaseNotesUrl,
    Info.moniker,
  ];
  final Infos infos;

  const PackageLongInfo(this.infos, {super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return Column(
      children: [
        TitleWidget(infos: infos),
        if (infos.hasDescription(locale))
          ExpandableCompartment(
            infos: infos,
            expandableInfo: Info.description,
          ),
        if (infos.hasReleaseNotes(locale))
          ExpandableCompartment(
            infos: infos,
            expandableInfo: Info.releaseNotes,
            buttonInfos: const [Info.releaseNotesUrl],
          ),
        if (DetailsWidget.containsData(infos.allDetails, locale))
          DetailsWidget(infos: infos),
        if (AgreementWidget.containsData(infos.allDetails, locale))
          AgreementWidget(infos: infos),
        if (InstallerDetails.containsData(infos.allDetails, locale))
          InstallerDetails(infos: infos),
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
        if (infos.details.hasInfo(Info.moniker, locale))
          SearchButton(
            searchTarget: infos.details[Info.moniker.key(locale)]!,
            local: locale,
          ),
        for (String tag in infos.tags!)
          SearchButton(
            searchTarget: tag,
            local: locale,
          )
      ],
    );
  }

  static Iterable<String> manuallyHandledStringKeys(AppLocalizations locale) =>
      manuallyHandledKeys.map<String>((Info info) => info.key(locale));

  static bool isManuallyHandled(String key, AppLocalizations locale) {
    return (manuallyHandledStringKeys(locale).contains(key) ||
            TitleWidget.manuallyHandledStringKeys(locale).contains(key) ||
            AgreementWidget.manuallyHandledStringKeys(locale).contains(key) ||
            DetailsWidget.manuallyHandledStringKeys(locale).contains(key)) ||
        InstallerDetails.manuallyHandledStringKeys(locale).contains(key);
  }
}
