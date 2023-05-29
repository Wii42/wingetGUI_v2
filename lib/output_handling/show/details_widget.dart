import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/extensions/string_map_extension.dart';
import 'package:winget_gui/output_handling/show/package_long_info.dart';

import '../info_enum.dart';
import 'Compartment.dart';

class DetailsWidget extends Compartment {
  const DetailsWidget({super.key, required super.infos});
  static final List<Info> manuallyHandledKeys = [
    Info.author,
    Info.id,
    Info.publisherSupportUrl,
    Info.documentation,
    Info.agreement,
    Info.pricing,
    Info.freeTrial,
    Info.ageRating,
  ];

  final String title = 'Details';

  @override
  List<Widget> buildCompartment(BuildContext context) {
    return fullCompartment(
        title: title,
        mainColumn: [
          ..._detailsList([
            Info.author,
            Info.agreement,
            Info.pricing,
            Info.freeTrial,
            Info.ageRating,
            Info.id,
            Info.documentation,
          ], context),
          ..._displayRest(context)
        ],
        buttonRow: buttonRow([Info.publisherSupportUrl], context),
        context: context);
  }

  List<Widget> _detailsList(List<Info> details, BuildContext context) {
    return [
      for (Info info in details)
        if (infos.hasEntry(info.key))
          wrapInWrap(
              title: info.title,
              body: checkIfTextIsLink(context: context, key: info.key)),
    ];
  }

  List<Widget> _displayRest(BuildContext context) {
    List<String> restKeys = [];
    for (String key in infos.keys) {
      if (!PackageLongInfo.isManuallyHandled(key)) {
        restKeys.add(key);
      }
    }
    return [
      for (String key in restKeys)
        if (infos.hasEntry(key))
          wrapInWrap(
              title: key, body: checkIfTextIsLink(context: context, key: key)),
    ];
  }

  static Iterable<String> manuallyHandledStringKeys() =>
      manuallyHandledKeys.map<String>((Info info) => info.key);

  static bool containsData(Map<String, String> infos) {
    for (String key in manuallyHandledStringKeys()) {
      if (infos.hasEntry(key) || !PackageLongInfo.isManuallyHandled(key)) {
        return true;
      }
    }
    return false;
  }
}
