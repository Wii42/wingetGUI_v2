import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/output_handling/package_infos/agreement_infos.dart';
import 'package:winget_gui/output_handling/package_infos/to_string_info_extensions.dart';

import '../../package_infos/info_with_link.dart';
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
            wrapInfoWithLink(context, infos.license),
          if (infos.copyright?.text != null)
            wrapInfoWithLink(context, infos.copyright),
        ],
        buttonRow: buttonRow([
          if (infos.license?.text == null) infos.license?.toUriInfoIfHasUrl(),
          if (infos.copyright?.text == null) infos.copyright?.toUriInfoIfHasUrl(),
          infos.privacyUrl,
          infos.buyUrl,
          infos.termsOfTransaction?.tryToUriInfo(),
          infos.seizureWarning?.tryToUriInfo(),
          infos.storeLicenseTerms?.tryToUriInfo(),
        ], context),
        context: context);
  }

  @override
  String compartmentTitle(AppLocalizations locale) {
    return PackageAttribute.agreement.title(locale);
  }
}
