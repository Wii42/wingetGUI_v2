import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:winget_gui/output_handling/output_handler.dart';
import 'package:winget_gui/package_actions_notifier.dart';
import 'package:winget_gui/widget_assets/command_button.dart';
import 'package:winget_gui/winget_process/un_installing_updating_page.dart';

import '../output_handling/package_infos/package_infos.dart';
import '../winget_commands.dart';
import '../winget_process/winget_process.dart';

class UnInstallingUpdatingButton extends CommandButton {
  final UnInstallingUpdatingType type;
  final PackageInfos infos;
  const UnInstallingUpdatingButton({
    super.key,
    required super.text,
    required super.command,
    super.title,
    super.icon,
    required this.type,
    required this.infos,
    super.disabled,
  });

  @override
  void Function()? onPressed(BuildContext context) => disabled
      ? null
      : () {
          UnInstallingUpdatingProcess process =
              UnInstallingUpdatingProcess.create(type,
                  args: args(infos, type.winget),
                  info: infos.toPeek(),
                  wingetLocale: OutputHandler.getWingetLocale(context));
          PackageAction action =
              PackageAction(process: process, infos: infos, type: type);
          Provider.of<PackageActionsNotifier>(context, listen: false)
              .add(action);
        };
}

class UnInstallingUpdatingIconButton extends CommandIconButton {
  final UnInstallingUpdatingType type;
  final PackageInfos infos;
  const UnInstallingUpdatingIconButton({
    super.key,
    required super.text,
    required super.command,
    super.title,
    required super.icon,
    this.type = UnInstallingUpdatingType.uninstall,
    super.padding = EdgeInsets.zero,
    required this.infos,
    super.disabled,
  });

  @override
  void Function()? onPressed(BuildContext context) => disabled
      ? null
      : () {
          UnInstallingUpdatingProcess process =
              UnInstallingUpdatingProcess.create(type,
                  args: args(infos, type.winget), info: infos.toPeek(),
                  wingetLocale: OutputHandler.getWingetLocale(context));
          PackageAction action =
              PackageAction(process: process, infos: infos, type: type);
          Provider.of<PackageActionsNotifier>(context, listen: false)
              .add(action);
        };
}

List<String> args(PackageInfos infos, Winget winget) {
  return [
    '--id',
    infos.id!.value,
    if (winget != Winget.upgrade && infos.hasVersion()) ...[
      '-v',
      infos.version!.value
    ],
  ];
}
