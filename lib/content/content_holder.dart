import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/helpers/stack.dart';

import 'content_pane.dart';
import 'content_snapshot.dart';

class ContentHolder extends InheritedWidget {
  final ContentPane content;
  final ListStack<ContentSnapshot> stack = ListStack();

  ContentHolder({super.key, required super.child, required this.content});

  @override
  bool updateShouldNotify(ContentHolder oldWidget) {
    return content != oldWidget.content;
  }

  static ContentHolder? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ContentHolder>();
  }

  static ContentHolder of(BuildContext context) {
    final ContentHolder? result = maybeOf(context);
    assert(result != null, 'No ContentHolder found in context');
    return result!;
  }
}
