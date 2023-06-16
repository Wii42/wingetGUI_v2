import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/helpers/extensions/string_map_extension.dart';
import 'package:winget_gui/output_handling/show/compartments/compartment.dart';

import '../../../helpers/extensions/string_extension.dart';
import '../../info_enum.dart';

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
          if (infos.details.hasInfo(Info.license) &&
              !isLink(infos.details[Info.license.key]))
            wrapInWrap(title: Info.license.title, body: _license(context)),
          if (infos.details.hasInfo(Info.copyright) &&
              !isLink(infos.details[Info.copyright.key]))
            wrapInWrap(title: Info.copyright.title, body: _copyright(context)),
        ],
        buttonRow: buttonRow([
          if (isLink(infos.details[Info.license.key])) Info.license,
          if (!infos.details.hasInfo(Info.license)) Info.licenseUrl,
          if (isLink(infos.details[Info.copyright.key])) Info.copyright,
          if (!infos.details.hasInfo(Info.copyright)) Info.copyrightUrl,
          Info.privacyUrl,
          Info.buyUrl,
          Info.termsOfTransaction,
          Info.seizureWarning,
          Info.storeLicenseTerms,
        ], context),
        context: context);
  }

  Widget _license(BuildContext context) {
    return textOrInlineLink(
        context: context, name: Info.license, url: Info.licenseUrl);
  }

  Widget _copyright(BuildContext context) {
    return textOrInlineLink(
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
