import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/package_infos/package_infos.dart';
import 'package:winget_gui/winget_process/package_action_type.dart';

import 'package_action_button.dart';

class RightSideButtons extends StatelessWidget {
  final PackageInfos infos;
  final MainAxisAlignment mainAlignment;
  final CrossAxisAlignment crossAlignment;
  final bool install, upgrade, uninstall;
  final bool showIcons;
  final bool iconsOnly;
  final bool showUnselectedOptionsAsDisabled;

  RightSideButtons(
      {required this.infos,
      super.key,
      this.mainAlignment = MainAxisAlignment.center,
      this.crossAlignment = CrossAxisAlignment.stretch,
      this.install = true,
      this.upgrade = true,
      this.uninstall = true,
      this.showIcons = true,
      this.iconsOnly = false,
      this.showUnselectedOptionsAsDisabled = false}) {
    assert(!iconsOnly || showIcons, 'iconsOnly requires showIcons to be true');
  }

  @override
  Widget build(BuildContext context) {
    return buttons([
      ButtonInfo(
          type: PackageActionType.install,
          visibility: ButtonVisibility.from(
              active: install,
              showIfInactive: showUnselectedOptionsAsDisabled)),
      ButtonInfo(
          type: PackageActionType.update,
          visibility: ButtonVisibility.from(
              active: upgrade,
              showIfInactive: showUnselectedOptionsAsDisabled)),
      ButtonInfo(
          type: PackageActionType.uninstall,
          visibility: ButtonVisibility.from(
              active: uninstall,
              showIfInactive: showUnselectedOptionsAsDisabled)),
    ], context);
  }

  Widget buttons(List<ButtonInfo> buttonInfos, BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return IntrinsicWidth(
      child: Column(
        mainAxisAlignment: mainAlignment,
        crossAxisAlignment: crossAlignment,
        children: buttonList(buttonInfos, locale),
      ),
    );
  }

  List<Widget> buttonList(
      List<ButtonInfo> buttonInfos, AppLocalizations locale) {
    Iterable<Widget?> list =
        buttonInfos.map<Widget?>((e) => createButton(e, locale));
    List<Widget> finalList = list.nonNulls.toList();
    if (iconsOnly) {
      return finalList;
    }
    return finalList.withSpaceBetween(height: 5);
  }

  Widget? createButton(ButtonInfo buttonInfo, AppLocalizations locale) {
    if (buttonInfo.visibility == ButtonVisibility.invisible) return null;
    String appName = infos.name?.value ?? infos.id!.value.string;
    PackageActionType command = buttonInfo.type;
    if (iconsOnly) {
      assert(command.winget.icon != null);
      return iconButton(command, locale, appName,
          disabled: buttonInfo.visibility.isDisabled);
    }
    return textButton(command, locale,
        disabled: buttonInfo.visibility.isDisabled);
  }

  Widget textButton(PackageActionType action, AppLocalizations locale,
      {required bool disabled}) {
    return PackageActionButton(
      type: action,
      infos: infos,
      disabled: disabled,
      locale: locale,
      showIcon: showIcons,
    );
  }

  Widget iconButton(
      PackageActionType action, AppLocalizations locale, String appName,
      {required bool disabled}) {
    return PackageActionIconButton(
      icon: action.winget.icon ?? FluentIcons.error,
      padding: numberOfButtons < 3
          ? const EdgeInsets.all(5)
          : const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      type: action,
      infos: infos,
      disabled: disabled,
    );
  }

  int get numberOfButtons {
    int number = 0;
    if (install) number++;
    if (upgrade) number++;
    if (uninstall) number++;
    return number;
  }
}

class ButtonInfo {
  final PackageActionType type;
  final ButtonVisibility visibility;
  const ButtonInfo({required this.type, required this.visibility});
}

enum ButtonVisibility {
  visible,
  disabled,
  invisible;

  const ButtonVisibility();
  factory ButtonVisibility.from(
      {required bool active, bool showIfInactive = false}) {
    if (active) {
      return ButtonVisibility.visible;
    } else {
      if (showIfInactive) {
        return ButtonVisibility.disabled;
      } else {
        return ButtonVisibility.invisible;
      }
    }
  }
  bool get isVisible => this == ButtonVisibility.visible;
  bool get isDisabled => this == ButtonVisibility.disabled;
  bool get isInvisible => this == ButtonVisibility.invisible;
}
