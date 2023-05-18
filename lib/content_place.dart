import 'package:fluent_ui/fluent_ui.dart';

import 'content.dart';

class ContentPlace extends InheritedWidget {
  final Content content;
  const ContentPlace({super.key, required super.child, required this.content});

  @override
  bool updateShouldNotify(ContentPlace oldWidget) {
    return content != oldWidget.content;
  }

  static ContentPlace? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ContentPlace>();
  }
}
