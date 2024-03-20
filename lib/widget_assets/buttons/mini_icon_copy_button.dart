import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:winget_gui/widget_assets/buttons/normal_button.dart';

import 'abstract_button.dart';
import 'mini_icon_link_button.dart';

class MiniIconCopyButton extends NormalButton
    with MiniIconButton, CustomToolTipMixin {
  final String copiedData;

  const MiniIconCopyButton({super.key, required this.copiedData});

  @override
  void onPressed(BuildContext context) =>
      Clipboard.setData(ClipboardData(text: copiedData));

  @override
  String get tooltipMessage => 'Copy to clipboard';

  @override
  IconData get icon => FluentIcons.copy;
}
