import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'abstract_button.dart';
import 'mini_icon_link_button.dart';
import 'normal_button.dart';

class MiniIconCopyButton extends NormalButton
    with MiniIconButton, CustomToolTipMixin {
  final String copiedData;

  const MiniIconCopyButton({super.key, required this.copiedData});

  @override
  void onPressed(BuildContext context) =>
      Clipboard.setData(ClipboardData(text: copiedData));

  @override
  String Function(AppLocalizations) get tooltipMessage =>
      (locale) => locale.copyToClipboardTooltip;

  @override
  IconData get icon => FluentIcons.copy;
}
