import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/widget_assets/run_button.dart';

import '../navigation_pages/search_page.dart';
import '../output_handling/package_infos/package_infos_peek.dart';
import '../winget_commands.dart';

const Winget winget = Winget.search;

class SearchButton extends RunButton with TextButtonMixin {
  final bool Function(PackageInfosPeek)? packageFilter;
  final String searchTarget;
  @override
  final IconData? icon = null;
  SearchButton({
    super.key,
    required this.searchTarget,
    required AppLocalizations localization,
    String? title,
    this.packageFilter,
  }) : super(command: [...winget.fullCommand, searchTarget]);

  @override
  BaseButton buttonType(
          {required Widget child, required VoidCallback? onPressed}) =>
      Button(onPressed: onPressed, child: child);

  @override
  void onPressed(BuildContext context) =>
      SearchPage.search(context, packageFilter: packageFilter)(searchTarget);
  @override
  String get buttonText => searchTarget;
}
