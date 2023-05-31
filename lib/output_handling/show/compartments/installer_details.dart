import 'package:fluent_ui/fluent_ui.dart';

import 'package:winget_gui/helpers/extensions/string_map_extension.dart';
import '../../info_enum.dart';
import 'compartment.dart';

class InstallerDetails extends Compartment {
  static final List<Info> manuallyHandledKeys = [
    Info.installerType,
    Info.storeProductID,
    Info.sha256Installer,
    Info.installerURL,
    Info.installerLocale,
    Info.releaseDate,
  ];

  final String title = 'Installer';

  const InstallerDetails({super.key, required super.infos});

  @override
  List<Widget> buildCompartment(BuildContext context) {
    return fullCompartment(
        title: title,
        mainColumn: [
          ..._installerDetailsList([
            Info.installerType,
            Info.storeProductID,
            Info.installerLocale,
            Info.sha256Installer,
            Info.releaseDate,
          ], context),
          ..._displayRest(context),
        ],
        buttonRow: buttonRow([Info.installerURL], context),
        context: context);
  }

  List<Widget> _displayRest(BuildContext context) {
    List<String> restKeys = [];
    for (String key in infos.installerDetails!.keys) {
      if (!isManuallyHandled(key)) {
        restKeys.add(key);
      }
    }
    return [
      for (String key in restKeys)
        if (infos.installerDetails!.hasEntry(key))
          wrapInWrap(
              title: key, body: checkIfTextIsLink(context: context, key: key)),
    ];
  }

  List<Widget> _installerDetailsList(List<Info> details, BuildContext context) {
    return [
      for (Info info in details)
        if (infos.installerDetails!.hasInfo(info))
          wrapInWrap(
              title: info.title,
              body: checkIfTextIsLink(context: context, key: info.key)),
    ];
  }

  static Iterable<String> manuallyHandledStringKeys() =>
      manuallyHandledKeys.map<String>((Info info) => info.key);

  static bool containsData(Map<String, String> infos) {
    for (String key in manuallyHandledStringKeys()) {
      if (infos.hasEntry(key)) {
        return true;
      }
    }
    return false;
  }

  static bool isManuallyHandled(String key) {
    return (manuallyHandledStringKeys().contains(key));
  }
}
