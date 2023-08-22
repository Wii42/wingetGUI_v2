import 'package:fluent_ui/fluent_ui.dart';

class FullWidthProgressbar extends StatelessWidget {
  const FullWidthProgressbar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SizedBox(
          height: 0,
          width: constraints.maxWidth,
          child: const ProgressBar(),
        );
      },
    );
  }
}