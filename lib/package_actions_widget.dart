import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/output_handling/output_handler.dart';
import 'package:winget_gui/output_handling/output_parser.dart';
import 'package:winget_gui/output_handling/show/show_parser.dart';
import 'package:winget_gui/package_actions_notifier.dart';
import 'package:winget_gui/widget_assets/decorated_card.dart';
import 'package:winget_gui/widget_assets/favicon_widget.dart';
import 'package:winget_gui/widget_assets/full_width_progress_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'output_handling/parsed_output.dart';

class PackageActionsList extends StatelessWidget {
  const PackageActionsList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PackageActionsNotifier>(
      builder: (BuildContext context, PackageActionsNotifier actionsNotifier,
          Widget? child) {
        return Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (PackageAction action in actionsNotifier.actions.reversed)
                PackageActionWidget(action: action),
            ].withSpaceBetween(height: 5),
          ),
        );
      },
    );
  }
}

class PackageActionWidget extends StatelessWidget {
  const PackageActionWidget({
    super.key,
    required this.action,
  });

  final PackageAction action;

  @override
  Widget build(BuildContext context) {
    AppLocalizations localization = AppLocalizations.of(context)!;
    return DecoratedCard(
      solidColor: true,
      child: StreamBuilder(
          stream: action.process.outputStream,
          builder: (context, snapshot) {
            closeWidgetAfterDone(context, snapshot);
            return Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (action.infos != null) ...[
                    const SizedBox(),
                    FaviconWidget(
                      infos: action.infos!,
                      faviconSize: 20,
                      withRightSiePadding: false,
                    ),
                  ] else
                    const SizedBox(
                      width: 10,
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: actionTitle(localization),
                  ),
                  outputField(snapshot, context),
                  if (snapshot.connectionState == ConnectionState.done)
                    IconButton(
                      icon: const Icon(FluentIcons.chrome_close),
                      onPressed: () => closeActionWidget(context),
                    ),
                  const SizedBox(width: 10),
                ].withSpaceBetween(width: 20));
          }),
    );
  }

  Text actionTitle(AppLocalizations locale) {
    String? optimalName;
    if (action.infos?.name != null) {
      optimalName = action.type?.winget
          .titleWithInput(action.infos!.name!.value, localization: locale);
    }
    return Text(
      optimalName ?? action.process.name ?? action.process.command.join(' '),
      style: const TextStyle(fontWeight: FontWeight.bold),
    );
  }

  Text fallbackText(AsyncSnapshot<List<String>> snapshot) =>
      Text(snapshot.hasData ? snapshot.data!.last : 'waiting...');

  void closeActionWidget(BuildContext context) {
    Provider.of<PackageActionsNotifier>(context, listen: false).remove(action);
  }

  void closeWidgetAfterDone(BuildContext context, AsyncSnapshot snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      PackageActionsNotifier actions =
          Provider.of<PackageActionsNotifier>(context, listen: false);
      Future.delayed(const Duration(seconds: 5))
          .then((value) => actions.remove(action));
    }
  }

  Widget outputField(
      AsyncSnapshot<List<String>> snapshot, BuildContext context) {
    AppLocalizations wingetLocale = OutputHandler.getWingetLocale(context);
    FutureOr<ParsedOutput>? output;
    if (snapshot.hasData) {
      OutputHandler handler =
          OutputHandler(snapshot.data!, command: action.process.command);
      handler.determineResponsibility(wingetLocale);
      OutputParser? lastPart = handler.outputParsers.lastOrNull;
      if (lastPart != null && lastPart is! ShowParser) {
        output = lastPart.parse(wingetLocale);
      }
      //output = handler.outputParsers.lastOrNull?.parse(wingetLocale);
    }
    return Expanded(
      child: Stack(
        children: [
          PositionedDirectional(
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 50),
              child: Center(
                child: Builder(
                  builder: (context) {
                    if (output != null && output is Future) {
                      return FutureBuilder<ParsedOutput>(
                          future: output as Future<ParsedOutput>,
                          builder: (context, futureSnapshot) =>
                              futureSnapshot.data?.widgetRepresentation() ??
                              fallbackText(snapshot));
                    } else if (output != null && output is ParsedOutput) {
                      return output.singleLineRepresentations().lastOrNull ??
                          fallbackText(snapshot);
                    } else {
                      return fallbackText(snapshot);
                    }
                  },
                ),
              ),
            ),
          ),
          if (snapshot.connectionState != ConnectionState.done &&
              snapshot.hasData)
            const FullWidthProgressbar(
              strokeWidth: 2,
            ),
        ],
      ),
    );
  }
}
