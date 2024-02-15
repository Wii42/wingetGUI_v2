import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/widget_assets/run_button.dart';

import '../navigation_pages/search_page.dart';
import '../output_handling/package_infos/package_infos_peek.dart';
import '../winget_commands.dart';

const Winget winget = Winget.search;

class SearchButton extends RunButton {
  final bool Function(PackageInfosPeek)? packageFilter;
  SearchButton({
    super.key,
    required String searchTarget,
    required AppLocalizations localization,
    String? title,
    this.packageFilter,
  }) : super(
            text: searchTarget,
            title: title ??
                winget.titleWithInput(searchTarget, localization: localization),
            command: [...winget.fullCommand, searchTarget]);

  @override
  BaseButton buttonType(BuildContext context) => Button(
      onPressed: () =>
          SearchPage.search(context, packageFilter: packageFilter)(text),
      child: child());
}
