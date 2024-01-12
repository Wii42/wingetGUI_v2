import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/widget_assets/command_button.dart';
import 'package:winget_gui/winget_process/un_installing_updating_page.dart';

class UnInstallingUpgradingButton extends CommandButton {
  final UnInstallingUpdatingType type;
  const UnInstallingUpgradingButton(
      {super.key,
      required super.text,
      required super.command,
      super.title,
      super.icon,
      required this.type});

  @override
  void Function() onPressed(BuildContext context) => () async {
        NavigatorState router = Navigator.of(context);
        UnInstallingUpdatingProcess process =
            await UnInstallingUpdatingProcess.run(type);
        router.push(FluentPageRoute(
            builder: (_) => UnInstallingUpdatingPage(
                  process: process,
                  title: title ?? "'$text'",
                )));
      };
}

class UnInstallingUpgradingIconButton extends CommandIconButton {
  final UnInstallingUpdatingType type;
  const UnInstallingUpgradingIconButton({
    super.key,
    required super.text,
    required super.command,
    super.title,
    required super.icon,
    this.type = UnInstallingUpdatingType.uninstall,
    super.padding = EdgeInsets.zero,
  });

  @override
  void Function() onPressed(BuildContext context) => () async {
        NavigatorState router = Navigator.of(context);
        UnInstallingUpdatingProcess process =
            await UnInstallingUpdatingProcess.run(type);
        router.push(FluentPageRoute(
            builder: (_) => UnInstallingUpdatingPage(
                  process: process,
                  title: title ?? "'$text'",
                )));
      };
}
