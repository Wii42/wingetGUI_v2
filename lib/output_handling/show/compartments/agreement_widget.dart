import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/output_handling/infos/agreement_infos.dart';
import 'package:winget_gui/output_handling/show/compartments/compartment.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../infos/app_attribute.dart';
import '../../infos/info.dart';

class AgreementWidget extends Compartment {

  final AgreementInfos infos;

  const AgreementWidget({super.key, required this.infos});

  @override
  List<Widget> buildCompartment(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return fullCompartment(
        title: compartmentTitle(locale),
        mainColumn: [
          if (infos.license?.text != null)
            wrapInWrap(
                title: AppAttribute.license.title(locale),
                body: _license(context)),
          if (infos.copyright?.text != null)
            wrapInWrap(
                title: AppAttribute.copyright.title(locale),
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
    return AppAttribute.agreement.title(locale);
  }

  Widget _license(BuildContext context) {
    return textOrInlineLink(
        context: context, text: infos.license?.text, url: infos.license?.url);
  }

  Widget _copyright(BuildContext context) {
    return textOrInlineLink(
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
