import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/widget_assets/buttons/run_button.dart';

import '../../navigation_pages/search_page.dart';
import '../../output_handling/package_infos/package_infos_peek.dart';
import '../../winget_commands.dart';
import 'abstract_button.dart';

const Winget winget = Winget.search;

class SearchButton extends RunButton with TextButtonMixin, PlainButtonMixin {
  final bool Function(PackageInfosPeek)? packageFilter;
  final String searchTarget;
  final String? customButtonText;
  @override
  SearchButton({
    super.key,
    required this.searchTarget,
    required AppLocalizations localization,
    String? title,
    this.customButtonText,
    this.packageFilter,
  }) : super(command: [...winget.fullCommand, searchTarget]);

  @override
  void onPressed(BuildContext context) =>
      SearchPage.search(context, packageFilter: packageFilter)(searchTarget);
  @override
  String get buttonText => customButtonText ?? searchTarget;
}

class FilledSearchButton extends SearchButton with FilledButtonMixin {
  FilledSearchButton(
      {super.key,
      required super.searchTarget,
      required super.localization,
      super.customButtonText,
      super.title,
      super.packageFilter});
}
