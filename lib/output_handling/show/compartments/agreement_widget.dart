import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/output_handling/package_infos/agreement_infos.dart';

import '../../package_infos/info.dart';
import '../../package_infos/package_attribute.dart';
import 'expander_compartment.dart';

class AgreementWidget extends ExpanderCompartment {
  final AgreementInfos infos;

  @override
  final IconData titleIcon = FluentIcons.commitments;

  const AgreementWidget({super.key, required this.infos});

  @override
  List<Widget> buildCompartment(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return fullCompartment(
        title: compartmentTitle(locale),
        mainColumn: [
          if (infos.license?.text != null)
            wrapInWrap(
                title: PackageAttribute.license.title(locale),
                body: _license(context)),
          if (infos.copyright?.text != null)
            wrapInWrap(
                title: PackageAttribute.copyright.title(locale),
                body: _copyright(context)),
        ],
        buttonRow: buttonRow([
          if (infos.license?.text == null) infos.license?.tryToInfoUri(),
          if (infos.copyright?.text == null) infos.copyright?.tryToInfoUri(),
          infos.privacyUrl,
          infos.buyUrl,
          tryFromStringInfo(infos.termsOfTransaction),
          tryFromStringInfo(infos.seizureWarning),
          tryFromStringInfo(infos.storeLicenseTerms),
        ], context),
        context: context);
  }

  @override
  String compartmentTitle(AppLocalizations locale) {
    return PackageAttribute.agreement.title(locale);
  }

  Widget _license(BuildContext context) {
    return textOrIconLink(
        context: context, text: infos.license?.text, url: infos.license?.url);
  }

  Widget _copyright(BuildContext context) {
    return textOrIconLink(
        context: context,
        text: infos.copyright?.text,
        url: infos.copyright?.url);
  }

  Info<Uri>? tryFromStringInfo(Info<String>? info) {
    if (info == null) return null;

    Uri? url = Uri.tryParse(info.value);
    if (url == null) return null;
    return Info<Uri>(title: info.title, value: url);
  }
}
