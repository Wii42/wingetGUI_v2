import 'package:fluent_ui/fluent_ui.dart';

import 'full_width_progress_bar.dart';

class FullWidthProgressBarOnTop extends StatelessWidget {
  final Widget child;
  final bool hasProgressBar;

  const FullWidthProgressBarOnTop(
      {super.key, required this.child, this.hasProgressBar = true});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(child: child),
        if (hasProgressBar) const FullWidthProgressbar(),
      ],
    );
  }
}
