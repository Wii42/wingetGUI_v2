import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/output_handling/loading_bar/loading_bar_parser.dart';

class LoadingBarBuilder extends StatelessWidget {
  final LoadingBar loadingBar;

  const LoadingBarBuilder(this.loadingBar, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          ProgressBar(
            value: loadingBar.value,
            backgroundColor: FluentTheme.of(context).accentColor.withAlpha(50),
          ),
          if (loadingBar.text != null) Text(loadingBar.text!),
        ],
      ),
    );
  }
}
