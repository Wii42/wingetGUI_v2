import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:winget_core/winget_core.dart';
import 'package:winget_gui/db/db_message.dart';
import 'package:winget_gui/l10n/generated/app_localizations.dart';
import 'package:winget_gui/winget_client/winget_client.dart';
import 'package:winget_gui/winget_client/winget_command.dart';

import '../../winget_commands.dart';
import '../../winget_process/package_action_type.dart';
import 'abstract_button.dart';
import 'normal_button.dart';

class PackageMultiActionButton extends NormalButton
    with
        TextButtonWithIconMixin,
        FilledButtonMixin,
        CustomToolTipMixin,
        RunPackageActionMixin {
  @override
  final WingetPackageActionCommand type;
  @override
  final List<PackageInfos> packages;
  final bool showIcon;
  final AppLocalizations locale;
  @override
  final LocalizedString tooltipMessage;

  PackageMultiActionButton({
    super.key,
    required this.type,
    required this.packages,
    super.disabled,
    this.showIcon = true,
    required this.locale,
    required this.tooltipMessage,
  });

  @override
  IconData? get icon => showIcon ? Winget.typeFromCmd(type)?.icon : null;

  @override
  String get buttonText => locale.actionOnAll(
    Winget.typeFromCmd(type)?.title(locale) ?? type.telemetryName,
  );
}

mixin RunPackageActionMixin on NormalButton {
  WingetPackageActionCommand get type;

  List<PackageInfos> get packages;

  @override
  void onPressed(BuildContext context) {
    WingetClient client = context.read<WingetClient>();
    for (var info in packages) {
      Info<PackageId>? id = info.id;
      if (id != null) {
        WingetPackageActionCommand specificCommand = type.copyWithId(
          id.value.string,
        );
        PackageActionType.runAction(specificCommand, info, context);
      }
    }
  }
}
