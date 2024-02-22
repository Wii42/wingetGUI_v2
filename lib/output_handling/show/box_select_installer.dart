import 'package:fluent_ui/fluent_ui.dart';

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

  ComboBoxItem<T> comboBoxItem(item) {
    return ComboBoxItem(
        value: item,
        child: Text(
          title(item),
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.red),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (categoryName.isNotEmpty)
          Text(categoryName, style: FluentTheme.of(context).typography.caption),
        ComboBox<T>(
          items: [
            for (T item in options) comboBoxItem(item),
            if (matchAll != null) comboBoxItem(matchAll),
          ],
          value: value,
          onChanged: onChanged,
          placeholder: const Text('null'),
        ),
      ],
    );
  }
}
