import 'package:fluent_ui/fluent_ui.dart';

import '../custom_combo_box.dart';

class BoxSelectInstaller<T> extends StatelessWidget {
  final String categoryName;
  final List<T> options;
  final String Function(T) title;
  final T? value;
  final void Function(T?)? onChanged;
  final T? matchAll;
  final bool Function(T?)? greyOutItem;

  const BoxSelectInstaller({
    super.key,
    required this.categoryName,
    required this.options,
    required this.title,
    this.value,
    this.onChanged,
    this.matchAll,
    this.greyOutItem,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (categoryName.isNotEmpty)
          Text(categoryName, style: FluentTheme.of(context).typography.caption),
        CustomComboBox<T>(
          items: [
            for (T item in options) comboBoxItem(item, context),
            if (matchAll != null) comboBoxItem(matchAll as T, context),
          ],
          value: value,
          onChanged: onChanged,
          placeholder: const Text('null'),
        ),
      ],
    );
  }

  ComboBoxItem<T> comboBoxItem(T item, BuildContext context) {
    FluentThemeData theme = FluentTheme.of(context);
    return ComboBoxItem(
        value: item,
        child: Text(
          title(item),
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              color: greyOutItem != null
                  ? (greyOutItem!(item)
                      ? theme.typography.body?.color?.withOpacity(0.3)
                      : null)
                  : null),
        ));
  }
}
