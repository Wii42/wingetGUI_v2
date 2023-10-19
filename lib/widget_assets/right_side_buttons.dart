import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';

import '../output_handling/package_infos/package_infos.dart';
import '../winget_commands.dart';
import 'command_button.dart';

class RightSideButtons extends StatelessWidget {
  final PackageInfos infos;
  final MainAxisAlignment mainAlignment;
  final CrossAxisAlignment crossAlignment;
  final bool install, upgrade, uninstall;
  final bool showIcons;
  final bool iconsOnly;

  RightSideButtons(
      {required this.infos,
      super.key,
      this.mainAlignment = MainAxisAlignment.center,
      this.crossAlignment = CrossAxisAlignment.stretch,
      this.install = true,
      this.upgrade = true,
      this.uninstall = true,
      this.showIcons = true,
      this.iconsOnly = false}) {
    assert(!iconsOnly || showIcons, 'iconsOnly requires showIcons to be true');
  }

  @override
  Widget build(BuildContext context) {
    return buttons([
      if (install) Winget.install,
      if (upgrade) Winget.upgrade,
      if (uninstall) Winget.uninstall
    ], context);
  }

  Widget buttons(List<Winget> commands, BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return IntrinsicWidth(
      child: Column(
        mainAxisAlignment: mainAlignment,
        crossAxisAlignment: crossAlignment,
        children: buttonList(commands, locale),
      ),
    );
  }

  List<Widget> buttonList(List<Winget> commands, AppLocalizations locale) {
    List<Widget> list = [
      for (Winget winget in commands) createButton(winget, locale),
    ];
    if (iconsOnly) {
      return list;
    }
    return list.withSpaceBetween(height: 5);
  }

  Widget createButton(Winget winget, AppLocalizations locale) {
    String appName = infos.name?.value ?? infos.id!.value;
    if (iconsOnly) {
      assert(winget.icon != null);
      return CommandIconButton(
        text: winget.title(locale),
        command: _createCommand(winget, locale),
        title: winget.titleWithInput(appName, localization: locale),
        icon: winget.icon ?? FluentIcons.error,
        padding: numberOfButtons < 3
            ? const EdgeInsets.all(5)
            : const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      );
    }
    return CommandButton(
      text: winget.title(locale),
      command: _createCommand(winget, locale),
      title: winget.titleWithInput(appName, localization: locale),
      icon: showIcons ? winget.icon : null,
    );
  }

  List<String> _createCommand(Winget winget, AppLocalizations locale) {
    return [
      ...winget.fullCommand,
      '--id',
      infos.id!.value,
      if (winget != Winget.upgrade && infos.hasVersion()) ...[
        '-v',
        infos.version!.value
      ]
    ];
  }

  int get numberOfButtons {
    int number = 0;
    if (install) number++;
    if (upgrade) number++;
    if (uninstall) number++;
    return number;
  }
}
