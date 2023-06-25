import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../info_enum.dart';
import 'compartment.dart';

class ExpandableCompartment extends Compartment {
  final String? title;
  final Info? expandableInfo;
  final List<Info>? buttonInfos;

  const ExpandableCompartment({
    super.key,
    required super.infos,
    this.title,
    this.expandableInfo,
    this.buttonInfos,
  });

  @override
  List<Widget> buildCompartment(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return fullCompartment(
        title: title ?? expandableInfo?.title(locale),
        mainColumn: (expandableInfo != null
            ? [
                textWithLinks(
                  key: expandableInfo!.key(locale),
                  context: context,
                  maxLines: 5,
                )
              ]
            : null),
        buttonRow:
            (buttonInfos != null ? buttonRow(buttonInfos!, context) : null),
        context: context);
  }
}
