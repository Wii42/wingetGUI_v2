import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/widget_assets/pane_item_body.dart';

import '../helpers/log_stream.dart';
import '../helpers/route_parameter.dart';

class LogPage extends StatelessWidget {
  const LogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PaneItemBody(
      title: 'Logs',
      child: StreamBuilder(
        stream: LogStream.instance.logsListStream,
        builder:
            (BuildContext context, AsyncSnapshot<List<LogMessage>> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: Text('No Logs yet...'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (BuildContext context, int index) {
              LogMessage log = snapshot.data![index];
              Type? displayType =
                  log.sourceType ?? log.sourceObject.runtimeType;
              return Text(
                  " ${log.time} $displayType: ${log.severity} ${log.message}");
            },
          );
        },
      ),
    );
  }

  static Widget inRoute(RouteParameter? parameters) {
    return const LogPage();
  }
}
