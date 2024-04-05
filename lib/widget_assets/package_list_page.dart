import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/db/db_message.dart';

import 'full_width_progress_bar_on_top.dart';
import 'package_peek_list_view.dart';
import 'pane_item_body.dart';

class PackageListPage extends StatelessWidget {
  final String? title;
  final PackagePeekListView listView;
  final void Function()? customReload;
  final Widget? bodyHeader;

  const PackageListPage(
      {super.key,
      required this.title,
      required this.listView,
      this.customReload,
      this.bodyHeader});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DBMessage>(
      stream: listView.reloadStream,
      initialData: DBMessage(listView.dbTable.status),
      builder: (context, snapshot) {
        return FullWidthProgressBarOnTop(
          hasProgressBar:
              snapshot.hasData && snapshot.data?.status == DBStatus.loading,
          child: PaneItemBody(
            title: title,
            bodyHeader: bodyHeader,
            customReload: customReload,
            goBackWithoutPreviousPage: () {
              listView.filterStreamController.add('');
            },
            child: listView,
          ),
        );
      },
    );
  }
}
