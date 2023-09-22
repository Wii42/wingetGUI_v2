import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/widget_assets/decorated_card.dart';

class InheritedSnackBar extends InheritedWidget {
  final SnackBarState snackBarState;
  const InheritedSnackBar(
      {super.key, required super.child, required this.snackBarState});

  @override
  bool updateShouldNotify(covariant InheritedSnackBar oldWidget) {
    return false;
  }
}

class SnackBar extends StatefulWidget {
  const SnackBar({super.key, required this.child});
  final Widget child;

  @override
  State<SnackBar> createState() => SnackBarState();

  static SnackBarState? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<InheritedSnackBar>()
        ?.snackBarState;
  }
}

class SnackBarState extends State<SnackBar>
    with AutomaticKeepAliveClientMixin<SnackBar> {
  Widget? snackBarChild;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return InheritedSnackBar(
      snackBarState: this,
      child: _buildWithSnackBar(widget.child),
    );
  }

  Widget _buildWithSnackBar(Widget child) {
    if (snackBarChild == null) return child;
    return Column(
      children: [
        Expanded(child: child),
        SizedBox(
          height: 50,
          child: DecoratedCard(child: Center(child: snackBarChild!)),
        )
      ],
    );
  }

  void showSnackBar(Widget? snackBarChild, {Duration? duration}) {
    setState(() {
      this.snackBarChild = snackBarChild;
    });
    if (duration != null) {
      Future.delayed(duration, () {
        showSnackBar(null);
      });
    }
  }

  @override
  bool get wantKeepAlive => true;
}
