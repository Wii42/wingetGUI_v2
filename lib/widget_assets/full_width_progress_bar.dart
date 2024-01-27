import 'package:fluent_ui/fluent_ui.dart';

class FullWidthProgressbar extends StatelessWidget {
  final double strokeWidth;
  const FullWidthProgressbar({super.key, this.strokeWidth = 4.5});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SizedBox(
          height: 3,
          width: constraints.maxWidth,
          child: ProgressBar(
            backgroundColor: Colors.transparent,
            strokeWidth: strokeWidth,
          ),
        );
      },
    );
  }
}
