import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/output_handling/output_handler.dart';
import 'package:winget_gui/output_handling/output_parser.dart';
import 'package:winget_gui/output_handling/show/show_parser.dart';
import 'package:winget_gui/package_actions_notifier.dart';
import 'package:winget_gui/widget_assets/decorated_card.dart';
import 'package:winget_gui/widget_assets/app_icon.dart';
import 'package:winget_gui/widget_assets/full_width_progress_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/winget_process/winget_process_scheduler.dart';

import 'output_handling/parsed_output.dart';

class PackageActionsList extends StatelessWidget {
  static const double spaceBetweenItems = 5;
  const PackageActionsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PackageActionsNotifier>(
      builder: (BuildContext context, PackageActionsNotifier actionsNotifier,
          Widget? child) {
        if (actionsNotifier.actions.isEmpty) return const SizedBox();
        return Column(
          children: [
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(10),
              child: actionsWidget(actionsNotifier),
            ),
          ],
        );
      },
    );
  }

  Widget actionsWidget(PackageActionsNotifier actionsNotifier) {
    if (actionsNotifier.actions.length == 1) {
      PackageAction action = actionsNotifier.actions.single;
      return PackageActionWidget(action: action, key: action.uniqueKey);
    }
    return Expander(
      header: PackageActionWidget(
          action: actionsNotifier.actions.first,
          key: actionsNotifier.actions.first.uniqueKey),
      direction: ExpanderDirection.up,
      content: Column(
        verticalDirection: VerticalDirection.up,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (PackageAction action in actionsNotifier.actions.skip(1))
            PackageActionWidget(action: action, key: action.uniqueKey),
        ].withSpaceBetween(height: PackageActionsList.spaceBetweenItems),
      ),
      contentPadding:
          const EdgeInsets.only(bottom: PackageActionsList.spaceBetweenItems),
      contentBackgroundColor: Colors.transparent,
      headerBackgroundColor: ButtonState.all(Colors.transparent),
      initiallyExpanded: true,
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
      child: FutureBuilder<int>(
          future: action.process.process.exitCode,
          builder: (context, exitCode) {
            closeWidgetAfterDone(context, exitCode);
            return Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(
                    width: 5,
                  ),
                  ...[
                    if (action.infos != null) ...[
                      AppIcon.fromInfos(
                        action.infos!,
                        iconSize: 30,
                        withRightSidePadding: false,
                      ),
                    ] else
                      const SizedBox(
                        width: 10,
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: actionTitle(localization),
                    ),
                    outputField(exitCode, context),
                          buttonAtEnd(exitCode, context),
                  ].withSpaceBetween(width: 20),
                  const SizedBox(width: 5)
                ]);
          }),
    );
  }

  Button button(IconData icon, String text, void Function() onPressed) =>
      Button(
        onPressed: onPressed,
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [Icon(icon), Text(text)].withSpaceBetween(width: 10)),
      );

  Widget buttonAtEnd(AsyncSnapshot<int> exitCode, BuildContext context){
    AppLocalizations localization = AppLocalizations.of(context)!;
    if (exitCode.hasData) {
      if (exitCode.data == 0) {
        return button(FluentIcons.accept, 'Ok',
                () => closeActionWidget(context));
      } else {
        return button(FluentIcons.error, 'Ok',
                () => closeActionWidget(context));
      }
    } else {
      return button(FluentIcons.chrome_close,
          localization.endProcess, () {
            ProcessScheduler.instance
                .removeProcess(action.process.process);
            closeActionWidget(context);
          });
    }
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

  Text fallbackText(
          AppLocalizations locale) =>
      Text(action.output.isNotEmpty ? action.output.last : locale.waiting);

  void closeActionWidget(BuildContext context) {
    Provider.of<PackageActionsNotifier>(context, listen: false).remove(action);
  }

  void closeWidgetAfterDone(
      BuildContext context, AsyncSnapshot<int> snapshot) async {
    if (snapshot.connectionState == ConnectionState.done) {
      PackageActionsNotifier actions =
          Provider.of<PackageActionsNotifier>(context, listen: false);
      int exitCode = await action.process.process.exitCode;
      if (exitCode == 0) {
        Future.delayed(const Duration(seconds: 5))
            .then((value) => actions.remove(action));
      }
    }
  }

  Widget outputField(AsyncSnapshot<int> exitCode,BuildContext context) {
    AppLocalizations wingetLocale = OutputHandler.getWingetLocale(context);
    AppLocalizations locale = AppLocalizations.of(context)!;
    FutureOr<ParsedOutput>? output;
    if (action.output.isNotEmpty) {
      OutputHandler handler =
          OutputHandler(action.output, command: action.process.command);
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
                              fallbackText(locale));
                    } else if (output != null && output is ParsedOutput) {
                      return output.singleLineRepresentations().lastOrNull ??
                          fallbackText(locale);
                    } else {
                      return fallbackText(locale);
                    }
                  },
                ),
              ),
            ),
          ),
          if (exitCode.connectionState != ConnectionState.done &&
              action.output.isNotEmpty)
            const FullWidthProgressbar(
              strokeWidth: 2,
            ),
        ],
      ),
    );
  }
}
