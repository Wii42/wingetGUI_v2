import 'package:fluent_ui/fluent_ui.dart';

abstract class OutputBuilder {
  Widget? widget;
  bool _isBuilt = false;
  OutputBuilder();

  Widget build(BuildContext context);

  Widget getWidget(BuildContext context) {
    if (!_isBuilt) {
      widget = build(context);
      _isBuilt = true;
    }
    return widget!;
  }

  bool get isBuilt => _isBuilt;
}

class QuickOutputBuilder extends OutputBuilder {
  final Widget Function(BuildContext) builder;

  QuickOutputBuilder(this.builder);

  @override
  Widget build(BuildContext context) => builder(context);
}
