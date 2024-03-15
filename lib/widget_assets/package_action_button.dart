import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/widget_assets/command_button.dart';

import '../output_handling/package_infos/package_infos.dart';
import '../winget_process/package_action_type.dart';

class PackageActionButton extends CommandButton {
  final PackageActionType type;
  final PackageInfos infos;
  const PackageActionButton({
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
  void Function()? onPressed(BuildContext context) =>
      disabled ? null : () => type.runAction(infos, context);
}

class PackageActionIconButton extends CommandIconButton {
  final PackageActionType type;
  final PackageInfos infos;
  const PackageActionIconButton({
    super.key,
    required super.text,
    required super.command,
    super.title,
    required super.icon,
    this.type = PackageActionType.uninstall,
    super.padding = EdgeInsets.zero,
    required this.infos,
    super.disabled,
  });

  @override
  void Function()? onPressed(BuildContext context) =>
      disabled ? null : () => type.runAction(infos, context);
}
