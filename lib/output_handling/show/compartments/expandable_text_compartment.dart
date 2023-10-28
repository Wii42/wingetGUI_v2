import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../widget_assets/link_text.dart';
import '../../package_infos/info.dart';
import 'expander_compartment.dart';

class ExpandableTextCompartment extends ExpanderCompartment {
  final Info<String> text;
  final Info<String>? title;
  final List<Info<Uri>?>? buttonInfos;

  const ExpandableTextCompartment({
    super.key,
    required this.text,
    this.title,
    this.buttonInfos,
  });

  @override
  List<Widget> buildCompartment(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return fullCompartment(
        title: compartmentTitle(locale),
        mainColumn: ([
          LinkText(
            line: text.value,
            title: title?.value,
            maxLines: 5,
          )
        ]),
        buttonRow:
            (buttonInfos != null ? buttonRow(buttonInfos!, context) : null),
        context: context);
  }

  @override
  String compartmentTitle(AppLocalizations locale) {
    return text.title(locale);
  }
}
