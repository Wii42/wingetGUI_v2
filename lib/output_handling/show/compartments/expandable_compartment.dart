import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../package_infos/info.dart';
import 'compartment.dart';

class ExpandableCompartment extends Compartment {
  final Info<String> text;
  final List<Info<Uri>?>? buttonInfos;

  const ExpandableCompartment({
    super.key,
    required this.text,
    this.buttonInfos,
  });

  @override
  List<Widget> buildCompartment(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return fullCompartment(
        title: compartmentTitle(locale),
        mainColumn: ([
          textWithLinks(
            text: text.value,
            context: context,
            maxLines: 5,
          )
        ]),
        buttonRow:
            (buttonInfos != null ? buttonRow(buttonInfos!, context) : null),
        context: context);
  }

  @override
  String? compartmentTitle(AppLocalizations locale) {
    return text.title(locale);
  }
}
