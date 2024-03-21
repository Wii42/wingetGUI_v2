import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/widget_assets/app_locale.dart';
import 'package:winget_gui/widget_assets/decorated_card.dart';
import 'package:winget_gui/widget_assets/pane_item_body.dart';

import '../helpers/log_stream.dart';
import '../helpers/route_parameter.dart';
import '../routes.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../widget_assets/buttons/page_button.dart';

class LogsPage extends StatefulWidget {
  const LogsPage({super.key});

  @override
  State<LogsPage> createState() => _LogsPageState();

  static Widget header(LogMessage log, BuildContext context) {
    Type? displayType = log.sourceObject?.runtimeType ?? log.sourceType;
    DateFormat formatter =
        DateFormat.Hms(AppLocale.of(context).guiLocale?.toLanguageTag());
    String metaInfo =
        [log.severity.displayName, displayType.toString()].join(' ');
    metaInfo += ':';
    Widget header = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(metaInfo),
            Expanded(
                child: Text(log.title,
                    maxLines: 1, overflow: TextOverflow.ellipsis)),
          ].withSpaceBetween(width: 5),
        ),
        Text(formatter.format(log.time),
            style: FluentTheme.of(context).typography.caption),
      ],
    );
    return header;
  }

  static Widget inRoute(RouteParameter? parameters) {
    return const LogsPage();
  }
}

class _LogsPageState extends State<LogsPage> {
  LogSeverity filter = LogSeverity.info;
  @override
  Widget build(BuildContext context) {
    return PaneItemBody(
      title: Routes.logsPage.title(AppLocalizations.of(context)!),
      child: Column(
        children: [
          severitySelector(),
          Expanded(
            child: StreamBuilder(
              stream: LogStream.instance.logsListStream,
              builder: (BuildContext context,
                  AsyncSnapshot<List<LogMessage>> snapshot) {
                List<LogMessage> data = LogStream.instance.messages;
                switch (filter) {
                  case LogSeverity.info:
                    break;
                  case LogSeverity.warning:
                    data = data
                        .where((element) =>
                            element.severity == LogSeverity.warning ||
                            element.severity == LogSeverity.error)
                        .toList();
                    break;
                  case LogSeverity.error:
                    data = data
                        .where(
                            (element) => element.severity == LogSeverity.error)
                        .toList();
                    break;
                }
                if (data.isEmpty) {
                  return const Center(child: Text('No Logs yet...'));
                }
                return ListView.builder(
                  itemCount: data.length,
                  prototypeItem: listItem(LogMessage.template(), context),
                  itemBuilder: (BuildContext context, int index) {
                    LogMessage log = data[index];
                    return listItem(log, context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Row severitySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (LogSeverity severity in LogSeverity.values)
          filter == severity
              ? FilledButton(
                  child: Text(severity.displayName),
                  onPressed: () {
                    setState(() {
                      filter = severity;
                    });
                  },
                )
              : Button(
                  child: Text(severity.displayName),
                  onPressed: () {
                    setState(() {
                      filter = severity;
                    });
                  },
                )
      ].withSpaceBetween(width: 10),
    );
  }

  Padding listItem(LogMessage log, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: DecoratedCard(
        padding: 10,
        child: Row(
          children: [
            Expanded(child: LogsPage.header(log, context)),
            if (log.message != null)
              PageIconButton(
                icon: FluentIcons.info,
                pageRoute: Routes.logDetailsPage,
                tooltipMessage: (locale) => locale.viewLogDetailsTooltip,
                routeParameter: LogRouteParameter(log: log),
              ),
          ],
        ),
      ),
    );
  }
}

class LogDetailsPage extends StatelessWidget {
  final LogMessage log;
  const LogDetailsPage(this.log, {super.key});

  @override
  Widget build(BuildContext context) {
    return PaneItemBody(
      title: Routes.logDetailsPage.title(AppLocalizations.of(context)!),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: [
            LogsPage.header(log, context),
            if (log.message != null)
              for (String line in log.message!.split('\n')) Text(line),
          ],
        ),
      ),
    );
  }

  static Widget inRoute(RouteParameter? parameters) {
    assert(parameters != null && parameters is LogRouteParameter,
        'LogDetailsPage: parameters must be a LogRouteParameter');
    LogRouteParameter log = parameters! as LogRouteParameter;
    return LogDetailsPage(log.log);
  }
}
