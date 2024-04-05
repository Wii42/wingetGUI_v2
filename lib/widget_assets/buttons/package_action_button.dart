import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/winget_process/package_action_type.dart';

import 'package:winget_gui/package_infos/package_infos.dart';
import 'abstract_button.dart';
import 'run_button.dart';

class PackageActionButton extends RunButton
    with TextButtonWithIconMixin, FilledButtonMixin, RunPackageActionMixin {
  @override
  final PackageActionType type;
  @override
  final PackageInfos infos;
  final bool showIcon;
  final AppLocalizations locale;
  PackageActionButton({
    super.key,
    required this.type,
    required this.infos,
    super.disabled,
    this.showIcon = true,
    required this.locale,
  }) : super(
          command: type.createCommand(infos),
        );

  @override
  IconData? get icon => showIcon ? type.winget.icon : null;

  @override
  String get buttonText => type.winget.title(locale);
}

class PackageActionIconButton extends RunButton
    with IconButtonMixin, RunPackageActionMixin {
  @override
  final PackageActionType type;
  @override
  final PackageInfos infos;
  @override
  final IconData icon;
  @override
  final EdgeInsetsGeometry padding;
  PackageActionIconButton({
    super.key,
    required this.icon,
    required this.type,
    this.padding = EdgeInsets.zero,
    required this.infos,
    super.disabled,
  }) : super(command: type.createCommand(infos));
}

mixin RunPackageActionMixin on RunButton {
  PackageActionType get type;

  PackageInfos get infos;

  @override
  void onPressed(BuildContext context) => type.runAction(infos, context);
}
