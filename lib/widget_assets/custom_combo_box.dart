import 'package:fluent_ui/fluent_ui.dart';

/// Small addons to [ComboBox]
class CustomComboBox<T> extends StatelessWidget {
  final List<ComboBoxItem<T>>? items;
  final T? value;
  final Widget? placeholder;
  final Widget? disabledPlaceholder;
  final ValueChanged<T?>? onChanged;
  final VoidCallback? onTap;
  final ComboBoxBuilder? selectedItemBuilder;
  final int elevation;
  final TextStyle? style;
  final Widget icon;
  final Color? iconDisabledColor;
  final Color? iconEnabledColor;
  final double iconSize;
  final bool isExpanded;
  final Color? focusColor;
  final FocusNode? focusNode;
  final bool autofocus;
  final Color? popupColor;

  const CustomComboBox({
    super.key,
    required this.items,
    this.selectedItemBuilder,
    this.value,
    this.placeholder,
    this.disabledPlaceholder,
    this.onChanged,
    this.onTap,
    this.elevation = 8,
    this.style,
    this.icon = const Icon(FluentIcons.chevron_down),
    this.iconDisabledColor,
    this.iconEnabledColor,
    this.iconSize = 8.0,
    this.isExpanded = false,
    this.focusColor,
    this.focusNode,
    this.autofocus = false,
    this.popupColor,
  });

  @override
  Widget build(BuildContext context) {
    return ComboBox(
      items: items,
      selectedItemBuilder: selectedItemBuilder,
      value: value,
      placeholder: placeholder,
      disabledPlaceholder: disabledPlaceholder,
      onChanged: onChanged,
      onTap: onTap,
      elevation: elevation,
      style: style,
      icon: icon,
      iconDisabledColor: iconDisabledColor,
      iconEnabledColor: iconEnabledColor,
      iconSize: iconSize,
      isExpanded: isExpanded,
      focusColor: focusColor,
      focusNode: focusNode,
      autofocus: autofocus,
      popupColor: popupColor ?? FluentTheme.of(context).accentColor,
    );
  }
}
