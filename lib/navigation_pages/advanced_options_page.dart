import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/helpers/route_parameter.dart';
import 'package:winget_gui/main_navigation.dart';
import 'package:winget_gui/routes.dart';
import 'package:winget_gui/widget_assets/pane_item_expander_body.dart';

class AdvancedOptionsPage extends StatelessWidget {
  const AdvancedOptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return PaneItemExpanderBody(
      title: Routes.advancedOptions.title(locale),
      children: MainNavigation.advancedFooterItems,
    );
  }

  factory AdvancedOptionsPage.inRoute([RouteParameter? params]) =>
      const AdvancedOptionsPage();
}
