import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/stack.dart';

import 'content.dart';

class ContentPlace extends InheritedWidget {
  final Content content;
  final ListStack<ContentSnapshot> stack = ListStack();
  ContentPlace({super.key, required super.child, required this.content});

  @override
  bool updateShouldNotify(ContentPlace oldWidget) {
    return content != oldWidget.content;
  }

  static ContentPlace? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ContentPlace>();
  }

  static ContentPlace of(BuildContext context) {
    final ContentPlace? result = maybeOf(context);
    assert(result != null, 'No ContentPlace found in context');
    return result!;
  }
}
