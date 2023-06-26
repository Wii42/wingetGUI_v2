import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../output_handling/info_enum.dart';
import '../winget_commands.dart';
import 'command_button.dart';

class RightSideButtons extends StatelessWidget {
  final Map<String, String> infos;
  final MainAxisAlignment alignment;

  const RightSideButtons(
      {required this.infos,
      super.key,
      this.alignment = MainAxisAlignment.center});

  @override
  Widget build(BuildContext context) {
    return buttons([Winget.install, Winget.upgrade, Winget.uninstall], context);
  }

  Widget buttons(List<Winget> commands, BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return Column(
      mainAxisAlignment: alignment,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (Winget winget in commands) createButton(winget, locale),
      ].withSpaceBetween(height: 5),
    );
  }

  CommandButton createButton(Winget winget, AppLocalizations locale) {
    return CommandButton(
      text: winget.title(locale),
      command: _createCommand(winget.command, locale),
      title: '${winget.title(locale)} ${infos[Info.name.key(locale)]}',
    );
  }

  List<String> _createCommand(List<String> command, AppLocalizations locale) {
    return [...command, '--id', infos[Info.id.key(locale)]!];
  }
}
