import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/widget_assets/full_width_progress_bar.dart';
import 'package:winget_gui/widget_assets/package_peek_list_view.dart';
import 'package:winget_gui/widget_assets/pane_item_body.dart';
import 'package:winget_gui/winget_db/db_message.dart';

import '../winget_process/winget_process.dart';
import 'full_width_progress_bar_on_top.dart';

class PackageListPage extends StatelessWidget {
  final String? title;
  final PackagePeekListView listView;
  final void Function()? customReload;

  const PackageListPage(
      {super.key,
      required this.title,
      required this.listView,
      this.customReload});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DBMessage>(
      stream: listView.reloadStream,
      initialData: DBMessage(DBStatus.ready),
      builder: (context, snapshot) {
        return FullWidthProgressBarOnTop(
          hasProgressBar:
              snapshot.hasData && snapshot.data?.status == DBStatus.loading,
          child: PaneItemBody(
            title: title,
            customReload: customReload,
            child: listView,
          ),
        );
      },
    );
  }
}
