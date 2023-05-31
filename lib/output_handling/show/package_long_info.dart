import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/helpers/extensions/string_map_extension.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/output_handling/show/compartments/agreement_widget.dart';
import 'package:winget_gui/output_handling/show/compartments/details_widget.dart';
import 'package:winget_gui/output_handling/show/compartments/expandable_compartment.dart';
import 'package:winget_gui/output_handling/show/compartments/installer_details.dart';
import 'package:winget_gui/output_handling/show/compartments/title_widget.dart';
import 'package:winget_gui/widget_assets/search_button.dart';

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
    return Column(
      children: [
        TitleWidget(infos: infos),
        if (infos.hasTags()) _tagButtons(context),
        if (infos.hasDescription())
          ExpandableCompartment(
            infos: infos,
            expandableInfo: Info.description,
          ),
        if (infos.hasReleaseNotes())
          ExpandableCompartment(
            infos: infos,
            expandableInfo: Info.releaseNotes,
            buttonInfos: const [Info.releaseNotesUrl],
          ),
        if (DetailsWidget.containsData(infos.allDetails)) DetailsWidget(infos: infos),
        if (AgreementWidget.containsData(infos.allDetails)) AgreementWidget(infos: infos),
        if (InstallerDetails.containsData(infos.allDetails))
          InstallerDetails(infos: infos),
      ].withSpaceBetween(height: 10),
    );
  }

  Widget _tagButtons(BuildContext context) {
    return Wrap(
      runSpacing: 5,
      spacing: 5,
      alignment: WrapAlignment.center,
      children: [
        if (infos.details.hasInfo(Info.moniker))
          SearchButton(searchTarget: infos.details[Info.moniker.key]!),
        for (String tag in infos.tags!) SearchButton(searchTarget: tag)
      ],
    );
  }

  static Iterable<String> manuallyHandledStringKeys() =>
      manuallyHandledKeys.map<String>((Info info) => info.key);

  static bool isManuallyHandled(String key) {
    return (manuallyHandledStringKeys().contains(key) ||
            TitleWidget.manuallyHandledStringKeys().contains(key) ||
            AgreementWidget.manuallyHandledStringKeys().contains(key) ||
            DetailsWidget.manuallyHandledStringKeys().contains(key)) ||
        InstallerDetails.manuallyHandledStringKeys().contains(key);
  }
}
