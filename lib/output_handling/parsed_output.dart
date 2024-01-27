import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';

abstract class ParsedOutput {
  Widget? widgetRepresentation() {
    List<Widget?> widgets = singleLineRepresentations();
    if (widgets.isEmpty) {
      return null;
    }
    if (widgets.length == 1) {
      return widgets.single;
    }
    return listWrapper(widgets.nonNulls.toList());
  }

  List<Widget?> singleLineRepresentations();

  Widget listWrapper(List<Widget> widgets) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets.withSpaceBetween(height: 5),
    );
  }
}
