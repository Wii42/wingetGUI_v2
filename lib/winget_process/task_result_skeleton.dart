import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/l10n/generated/app_localizations.dart';

import '../widget_assets/scroll_list_widget.dart';
import '../winget_client/winget_client.dart';

abstract class TaskResultSkeleton<T extends Object> extends StatelessWidget {
  final WingetTask<T> task;

  const TaskResultSkeleton({required this.task, super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      stream: task.result,
      builder: (BuildContext context, AsyncSnapshot<T> streamSnapshot) {
        return buildPage(streamSnapshot, context);
      },
    );
  }

  List<Widget> outputList(
    AsyncSnapshot<T> streamSnapshot,
    BuildContext context,
  ) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return [
      if (streamSnapshot.hasData) onData(streamSnapshot.data!, context),
      if (streamSnapshot.hasError) onError(streamSnapshot),
      if (isWaitingOnData(streamSnapshot)) onWaiting(locale),
    ];
  }

  Widget buildPage(AsyncSnapshot<T> streamSnapshot, BuildContext context);

  Widget onWaiting(AppLocalizations locale) {
    return Expanded(child: Center(child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ProgressRing(backgroundColor: Colors.transparent),
        const SizedBox(height: 10),
        Text(locale.waitOnData),
      ],
    )));
  }

  bool isWaitingOnData(AsyncSnapshot<T> streamSnapshot) {
    return !(streamSnapshot.hasData ||
        streamSnapshot.hasError ||
        streamSnapshot.connectionState == ConnectionState.done);
  }

  Widget onError(AsyncSnapshot<T> streamSnapshot) =>
      Center(child: Text(streamSnapshot.error.toString()));

  Widget onData(T data, BuildContext context);
}

mixin TextListMixin on TaskResultSkeleton<List<String>> {
  @override
  Widget onData(List<String> data, BuildContext context) {
    return Expanded(
      child: ScrollListWidget(
        listElements: data
            .map((e) => Text(e))
            .toList()
            .withSpaceBetween(height: 10),
      ),
    );
  }
}
