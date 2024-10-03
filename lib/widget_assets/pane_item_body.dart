import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/winget_process/output_page.dart';
import 'package:winget_gui/winget_process/winget_process.dart';

class PaneItemBody extends StatelessWidget {
  static const double iconSize = 40;
  static const double maxWidth = 1200;

  final String? title;
  final Widget child;
  final IconData? icon;
  final WingetProcess? process;
  final void Function()? customReload;
  final void Function()? goBackWithoutPreviousPage;
  final Widget? bodyHeader;

  const PaneItemBody(
      {super.key,
      required this.title,
      required this.child,
      this.process,
      this.customReload,
      this.bodyHeader,
      this.goBackWithoutPreviousPage,
      this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxWidth),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null ||
                process != null ||
                canGoBack(context) ||
                customReload != null ||
                icon != null)
              titleRow(context),
            if (bodyHeader != null) bodyHeader!,
            Expanded(child: child),
          ],
        ),
      ),
    );
  }

  Padding titleRow(BuildContext context) {
    NavigatorState navigator = Navigator.of(context);
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
              width: iconSize,
              height: iconSize,
              child: IconButton(
                  onPressed: hasPreviousPage(context)
                      ? navigator.maybePop
                      : goBackWithoutPreviousPage,
                  icon: const Icon(
                    FluentIcons.back,
                  ))),
          if (icon != null || title != null) const SizedBox(width: 0),
          if (icon != null) Icon(icon),
          if (title != null)
            Expanded(
              child: Text(
                title!,
                style: FluentTheme.of(context).typography.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          if (process != null || customReload != null)
            SizedBox(
              width: iconSize,
              height: iconSize,
              child: IconButton(
                onPressed: customReload ??
                    () {
                      WingetProcess newProcess = process!.clone();
                      navigator.pushReplacement(
                        FluentPageRoute(
                          builder: (_) => OutputPage(
                            process: newProcess,
                            title: title != null ? (_) => title! : null,
                          ),
                        ),
                      );
                    },
                icon: const Icon(FluentIcons.update_restore),
              ),
            )
        ].withSpaceBetween(width: 10),
      ),
    );
  }

  bool hasPreviousPage(BuildContext context) => Navigator.of(context).canPop();

  bool canGoBack(BuildContext context) =>
      goBackWithoutPreviousPage != null || hasPreviousPage(context);

  factory PaneItemBody.inRoute([Object? _]) =>
      const PaneItemBody(title: 'empty', child: Text('text'));
}
