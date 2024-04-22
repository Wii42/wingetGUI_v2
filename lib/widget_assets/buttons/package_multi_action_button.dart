import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/db/db_message.dart';
import 'package:winget_gui/package_infos/package_infos.dart';
import 'package:winget_gui/winget_process/package_action_type.dart';

import 'abstract_button.dart';
import 'normal_button.dart';

class PackageMultiActionButton extends NormalButton
    with
        TextButtonWithIconMixin,
        FilledButtonMixin,
        CustomToolTipMixin,
        RunPackageActionMixin {
  @override
  final PackageActionType type;
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
  IconData? get icon => showIcon ? type.winget.icon : null;

  @override
  String get buttonText => locale.actionOnAll(type.winget.title(locale));
}

mixin RunPackageActionMixin on NormalButton {
  PackageActionType get type;

  List<PackageInfos> get packages;

  @override
  void onPressed(BuildContext context) {
    for (var info in packages) {
      type.runAction(info, context);
    }
  }
}
