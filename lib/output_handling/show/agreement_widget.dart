import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/extensions/string_map_extension.dart';
import 'package:winget_gui/extensions/widget_list_extension.dart';
import 'package:winget_gui/output_handling/show/Compartment.dart';

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

  const AgreementWidget({super.key, required super.infos});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Agreement', style: FluentTheme.of(context).typography.title),
          if (infos.hasEntry(Info.license.key) ||
              infos.hasEntry(Info.licenseUrl.key))
            wrapInWrap(title: 'License', body: _license(context)),
          if (infos.hasEntry(Info.copyright.key) ||
              infos.hasEntry(Info.copyrightUrl.key))
            wrapInWrap(title: 'Copyright', body: _copyright(context)),
          _buttonRow(context),
        ].withSpaceBetween(height: 5),
      ),
    );
  }



  Widget _license(BuildContext context) {
    return textOrLink(
        context: context, name: Info.license, url: Info.licenseUrl);
  }

  Widget _copyright(BuildContext context) {
    return textOrLink(
        context: context, name: Info.copyright, url: Info.copyrightUrl);
  }

  Widget _buttonRow(BuildContext context) {
    return Wrap(
      spacing: 5,
      runSpacing: 5,
      crossAxisAlignment: WrapCrossAlignment.start,
      children: [
        if (infos.hasEntry(Info.privacyUrl.key))
          checkIfTextIsLink(
              context: context, name: Info.privacyUrl, title: 'Privacy'),
        if (infos.hasEntry(Info.buyUrl.key))
          checkIfTextIsLink(context: context, name: Info.buyUrl, title: 'Buy'),
        if (infos.hasEntry(Info.termsOfTransaction.key))
          checkIfTextIsLink(
              context: context,
              name: Info.termsOfTransaction,
              title: 'Terms of Transaction'),
        if (infos.hasEntry(Info.seizureWarning.key))
          checkIfTextIsLink(
              context: context,
              name: Info.seizureWarning,
              title: 'Seizure Warning'),
        if (infos.hasEntry(Info.storeLicenseTerms.key))
          checkIfTextIsLink(
              context: context,
              name: Info.storeLicenseTerms,
              title: 'Store License Terms'),
      ],
    );
  }

  static Iterable<String> manuallyHandledStringKeys() =>
      manuallyHandledKeys.map<String>((Info info) => info.key);

  static bool containsData(Map<String, String> infos) {
    for(String key in manuallyHandledStringKeys()){
      if(infos.hasEntry(key)){
        return true;
      }
    }
    return false;
  }
}
