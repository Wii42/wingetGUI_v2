import 'package:fluent_ui/fluent_ui.dart';
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
      : () async {
          NavigatorState router = Navigator.of(context);
          UnInstallingUpdatingProcess process =
              await UnInstallingUpdatingProcess.run(type,
                  args: args(infos, type.winget));
          router.push(FluentPageRoute(
              builder: (_) => UnInstallingUpdatingPage(
                    process: process,
                    title: title ?? "'$text'",
                  )));
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
      : () async {
          NavigatorState router = Navigator.of(context);
          UnInstallingUpdatingProcess process =
              await UnInstallingUpdatingProcess.run(type,
                  args: args(infos, type.winget));
          router.push(FluentPageRoute(
              builder: (_) => UnInstallingUpdatingPage(
                    process: process,
                    title: title ?? "'$text'",
                  )));
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
