import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/output_handling/loading_bar/loading_bar_parser.dart';
import 'package:winget_gui/output_handling/output_builder.dart';

class LoadingBarBuilder extends OutputBuilder {
  final LoadingBar loadingBar;

  LoadingBarBuilder(this.loadingBar);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ProgressBar(
          value: loadingBar.value,
          backgroundColor: FluentTheme.of(context).accentColor.withAlpha(50),
        ),
        if (loadingBar.text != null) Text(loadingBar.text!),
      ],
    );
  }
}
