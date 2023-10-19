import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/widget_assets/run_button.dart';

import '../winget_commands.dart';

const Winget winget = Winget.search;

class SearchButton extends RunButton {
  const SearchButton.create(
      {super.key, required super.text, super.title, required super.command});

  SearchButton({
    super.key,
    required String searchTarget,
    required AppLocalizations localization,
    String? title,
  }) : super(
            text: searchTarget,
            title: title ??
                winget.titleWithInput(searchTarget, localization: localization),
            command: [...winget.fullCommand, searchTarget]);

  @override
  BaseButton buttonType(BuildContext context) =>
      Button(onPressed: onPressed(context), child: child());
}
