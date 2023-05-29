import 'package:expandable_text/expandable_text.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:string_validator/string_validator.dart';
import 'package:winget_gui/extensions/string_map_extension.dart';
import 'package:winget_gui/link_text.dart';
import 'package:winget_gui/output_handling/show/show_part.dart';

import '../info_enum.dart';
import 'Compartment.dart';
import 'link_button.dart';

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
  late final Map<String, String> installer;

  InstallerDetails({super.key, required super.infos}) {
    installer = ShowPart.extractDetails(infos[Info.installer.key]!
        .split('\n')
        .map((String line) => line.trim())
        .toList());
  }

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
    for (String key in installer.keys) {
      if (!isManuallyHandled(key)) {
        restKeys.add(key);
      }
    }
    return [
      for (String key in restKeys)
        if (installer.hasEntry(key))
          wrapInWrap(
              title: key, body: checkIfTextIsLink(context: context, key: key)),
    ];
  }

  List<Widget> _installerDetailsList(List<Info> details, BuildContext context) {
    return [
      for (Info info in details)
        if (installer.hasEntry(info.key))
          wrapInWrap(
              title: info.title,
              body: checkIfTextIsLink(context: context, key: info.key)),
    ];
  }

  @override
  Widget checkIfTextIsLink(
      {required BuildContext context, required String key, String? title}) {
    String text = installer[key]!.trim();
    if (isURL(text) ||
        (text.startsWith('ms-windows-store://') && !text.contains(' '))) {
      return LinkButton(url: text, text: Text(title ?? text));
    }
    return LinkText(line: text, maxLines: 1,);
  }

  @override
  Wrap buttonRow(List<Info> links, BuildContext context) {
    return Wrap(
      spacing: 5,
      runSpacing: 5,
      crossAxisAlignment: WrapCrossAlignment.start,
      children: [
        for (Info info in links)
          if (installer.hasEntry(info.key))
            checkIfTextIsLink(
                context: context, key: info.key, title: info.title),
      ],
    );
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
