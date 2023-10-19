import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/widget_assets/decorated_card.dart';

class SnackBarWrapper extends StatelessWidget {
  const SnackBarWrapper({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InheritedSnackBar(
      child: Column(
        children: [
          Expanded(child: child),
          const SnackBar(),
        ],
      ),
    );
  }

  static SnackBarHolder? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<InheritedSnackBar>()
        ?.snackBarHolder;
  }
}

class InheritedSnackBar extends InheritedWidget {
  final SnackBarHolder snackBarHolder = SnackBarHolder();
  InheritedSnackBar({super.key, required super.child});

  @override
  bool updateShouldNotify(covariant InheritedSnackBar oldWidget) {
    return snackBarHolder.snackBar != oldWidget.snackBarHolder.snackBar;
  }

  static SnackBarHolder? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<InheritedSnackBar>()
        ?.snackBarHolder;
  }
}

class SnackBar extends StatelessWidget {
  const SnackBar({super.key});

  @override
  Widget build(BuildContext context) {
    Widget? snackBar = SnackBarWrapper.of(context)!.snackBar;
    if (snackBar == null) {
      return const SizedBox();
    }
    return SizedBox(
        height: 50,
        child: DecoratedCard(
            child: Center(child: SnackBarWrapper.of(context)!.snackBar)));
  }
}

class SnackBarHolder {
  Widget? snackBar;

  void showSnackBar(Widget? snackBar, {Duration? duration}) {
    this.snackBar = snackBar;
    if (duration != null) {
      Future.delayed(duration, () {
        removeSnackBar();
      });
    }
  }

  void removeSnackBar() {
    snackBar = null;
  }
}
