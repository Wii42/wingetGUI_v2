import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/output_handling/package_infos/package_attribute.dart';
import 'package:winget_gui/output_handling/show/compartments/expander_compartment.dart';

import '../../../widget_assets/buttons/search_button.dart';
import '../../package_infos/info.dart';

class TagsWidget extends ExpanderCompartment {
  final List<String> tags;
  final Info<String>? moniker;

  const TagsWidget({super.key, required this.tags, this.moniker});

  @override
  List<Widget> buildCompartment(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return fullCompartment(
        title: compartmentTitle(locale),
        buttonRow: _tagButtons(context),
        context: context);
  }

  @override
  String compartmentTitle(AppLocalizations locale) {
    return PackageAttribute.tags.title(locale);
  }

  @override
  IconData get titleIcon => FluentIcons.tag;

  Wrap _tagButtons(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return Wrap(
      runSpacing: 5,
      spacing: 5,
      children: [
        if (moniker != null)
          SearchButton(
            searchTarget: moniker!.value,
            localization: locale,
          ),
        for (String tag in tags)
          SearchButton(
            searchTarget: tag,
            localization: locale,
          )
      ],
    );
  }
}
