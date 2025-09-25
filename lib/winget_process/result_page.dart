import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:winget_gui/l10n/generated/app_localizations.dart';
import 'package:winget_gui/package_infos/package_infos_full.dart';
import 'package:winget_gui/widget_assets/full_width_progress_bar_on_top.dart';
import 'package:winget_gui/widget_assets/pane_item_body.dart';

import '../widget_assets/package_long_info/package_long_info.dart';
import '../winget_client/winget_client.dart';
import '../winget_commands.dart';
import 'task_result_skeleton.dart';

abstract class ResultPage<T extends Object> extends TaskResultSkeleton<T> {
  final String Function(AppLocalizations)? title;

  const ResultPage({required super.task, super.key, this.title});

  @override
  Widget buildPage(AsyncSnapshot<T> streamSnapshot, BuildContext context) {
    return FullWidthProgressBarOnTop(
      hasProgressBar: streamSnapshot.connectionState != ConnectionState.done,
      child: PaneItemBody(
        title: title != null ? title!(AppLocalizations.of(context)!) : null,
        child: processOutput(streamSnapshot, context),
      ),
    );
  }

  Widget processOutput(AsyncSnapshot<T> streamSnapshot, BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: [
        ...outputList(streamSnapshot, context),
        if (streamSnapshot.connectionState != ConnectionState.done)
          stopButton(context),
      ],
    );
  }

  Padding stopButton(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Button(
        onPressed: () {
          WingetClient client = context.read<WingetClient>();
          task.cancel(client);
        },
        child: Text(locale.endProcess),
      ),
    );
  }

  @override
  Widget onData(T data, BuildContext context);
}

class TextResultPage extends ResultPage<List<String>> with TextListMixin {
  TextResultPage({super.key, required super.task, super.title});
}

class PackageInfosFullPage extends ResultPage<PackageInfosFull> {
  final String? titleInput;

  PackageInfosFullPage({super.key, required super.task, this.titleInput})
    : super(
        title: (locale) {
          return titleInput != null
              ? Winget.show.titleWithInput(titleInput, localization: locale)
              : Winget.show.title(locale);
        },
      );

  @override
  Widget processOutput(AsyncSnapshot<PackageInfosFull> streamSnapshot, BuildContext context) {
    if (streamSnapshot.hasData){
      return onData(streamSnapshot.data!, context);
    }
    return super.processOutput(streamSnapshot, context);
  }

  @override
  Widget onData(PackageInfosFull data, BuildContext context) {
    EdgeInsetsGeometry padding = const EdgeInsets.all(10);
    return SingleChildScrollView(physics: BouncingScrollPhysics(),padding: padding,child: PackageLongInfo(data),);
  }
}
