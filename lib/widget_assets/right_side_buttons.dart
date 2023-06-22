import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../output_handling/info_enum.dart';
import '../winget_commands.dart';
import 'command_button.dart';

class RightSideButtons extends StatelessWidget {
  final Map<String, String> infos;

  const RightSideButtons({required this.infos, super.key});

  @override
  Widget build(BuildContext context) {
    return buttons([Winget.install, Winget.upgrade, Winget.uninstall], context);
  }

  Widget buttons(List<Winget> commands, BuildContext context) {
    AppLocalizations local = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (Winget winget in commands) createButton(winget, local),
      ].withSpaceBetween(height: 5),
    );
  }

  CommandButton createButton(Winget winget, AppLocalizations local) {
    return CommandButton(
      text: winget.name(local),
      command: _createCommand(winget.command),
      title: '${winget.name(local)} ${infos[Info.name.key]}',
    );
  }

  List<String> _createCommand(List<String> command) {
    return [...command, '--id', infos[Info.id.key]!];
  }
}
