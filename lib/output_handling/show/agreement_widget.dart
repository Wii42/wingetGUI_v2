import 'package:fluent_ui/fluent_ui.dart';
import 'package:string_validator/string_validator.dart';
import 'package:winget_gui/extensions/string_map_extension.dart';
import 'package:winget_gui/output_handling/show/compartment.dart';

import '../info_enum.dart';

class AgreementWidget extends Compartment {
  static final List<Info> manuallyHandledKeys = [
    Info.license,
    Info.licenseUrl,
    Info.copyright,
    Info.copyrightUrl,
    Info.privacyUrl,
    Info.buyUrl,
    Info.termsOfTransaction,
    Info.seizureWarning,
    Info.storeLicenseTerms,
  ];

  final String title = 'Agreement';

  const AgreementWidget({super.key, required super.infos});

  @override
  List<Widget> buildCompartment(BuildContext context) {
    return fullCompartment(
        title: title,
        mainColumn: [
          if (infos.hasEntry(Info.license.key) &&
              !isURL(infos[Info.license.key]))
            wrapInWrap(title: Info.license.title, body: _license(context)),
          if (infos.hasEntry(Info.copyright.key) ||
              infos.hasEntry(Info.copyrightUrl.key))
            wrapInWrap(title: Info.copyright.title, body: _copyright(context)),
        ],
        buttonRow: buttonRow([
          if (isURL(infos[Info.license.key])) Info.license,
          if (!infos.hasEntry(Info.license.key)) Info.licenseUrl,
          Info.privacyUrl,
          Info.buyUrl,
          Info.termsOfTransaction,
          Info.seizureWarning,
          Info.storeLicenseTerms,
        ], context),
        context: context);
  }

  Widget _license(BuildContext context) {
    return textOrLink(
        context: context, name: Info.license, url: Info.licenseUrl);
  }

  Widget _copyright(BuildContext context) {
    return textOrLink(
        context: context, name: Info.copyright, url: Info.copyrightUrl);
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
}
