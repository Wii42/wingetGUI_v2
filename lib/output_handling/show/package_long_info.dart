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

class PackageLongInfo extends StatelessWidget {
  static final List<Info> manuallyHandledKeys = [
    Info.description,
    Info.tags,
    Info.releaseNotes,
    Info.installer,
    Info.releaseNotesUrl,
    Info.moniker,
  ];
  final Map<String, String> infos;

  const PackageLongInfo(this.infos, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TitleWidget(infos: infos),
        if (infos.hasEntry(Info.tags.key)) _tagButtons(context),
        if (infos.hasEntry(Info.description.key))
          ExpandableCompartment(
            infos: infos,
            expandableInfo: Info.description,
          ),
        if (infos.hasEntry(Info.releaseNotes.key))
          ExpandableCompartment(
            infos: infos,
            expandableInfo: Info.releaseNotes,
            buttonInfos: const [Info.releaseNotesUrl],
          ),
        if (DetailsWidget.containsData(infos)) DetailsWidget(infos: infos),
        if (AgreementWidget.containsData(infos)) AgreementWidget(infos: infos),
        if (InstallerDetails.containsData(infos))
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
        if (infos.hasEntry(Info.moniker.key))
          SearchButton(searchTarget: infos[Info.moniker.key]!),
        for (String tag in tags) SearchButton(searchTarget: tag)
      ],
    );
  }

  List<String> get tags {
    List<String> split = infos[Info.tags.key]!.split('\n');
    List<String> tags = [];
    for (String s in split) {
      if (s.isNotEmpty) {
        tags.add(s.trim());
      }
    }
    return tags;
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

  bool existUnhandledKeys() {
    for (String key in infos.keys) {
      if (!isManuallyHandled(key)) {
        return true;
      }
    }
    return false;
  }
}
