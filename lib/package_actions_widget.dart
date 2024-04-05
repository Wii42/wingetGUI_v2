import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/output_handling/output_handler.dart';
import 'package:winget_gui/output_handling/output_parser.dart';
import 'package:winget_gui/output_handling/show/show_parser.dart';
import 'package:winget_gui/package_actions_notifier.dart';
import 'package:winget_gui/widget_assets/app_icon.dart';
import 'package:winget_gui/widget_assets/custom_expander.dart';
import 'package:winget_gui/widget_assets/decorated_card.dart';
import 'package:winget_gui/widget_assets/full_width_progress_bar.dart';
import 'package:winget_gui/winget_process/winget_process_scheduler.dart';

import 'package:winget_gui/output_handling/parsed_output.dart';

class PackageActionsList extends StatelessWidget {
  final double maxListHeight;
  static const double spaceBetweenItems = 5;
  const PackageActionsList({super.key, required this.maxListHeight});

  @override
  Widget build(BuildContext context) {
    return Consumer<PackageActionsNotifier>(
      builder: (BuildContext context, PackageActionsNotifier actionsNotifier,
          Widget? child) {
        if (actionsNotifier.actions.isEmpty) return const SizedBox();
        return DecoratedCard(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
          hasBorder: false,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: actionsWidget(actionsNotifier),
          ),
        );
      },
    );
  }

  Widget actionsWidget(PackageActionsNotifier actionsNotifier) {
    if (actionsNotifier.actions.length == 1) {
      PackageAction action = actionsNotifier.actions.single;
      return PackageActionWidget(action: action, key: action.uniqueKey);
    }
    return CustomExpander(
      header: PackageActionWidget(
          action: actionsNotifier.actions.first,
          key: actionsNotifier.actions.first.uniqueKey),
      direction: ExpanderDirection.up,
      content: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxListHeight),
        child: ListView(
          reverse: true,
          shrinkWrap: true,
          children: [
            for (PackageAction action in actionsNotifier.actions.skip(1))
              PackageActionWidget(action: action, key: action.uniqueKey),
          ].withSpaceBetween(height: PackageActionsList.spaceBetweenItems),
        ),
      ),
      contentPadding:
          const EdgeInsets.only(bottom: PackageActionsList.spaceBetweenItems),
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
      child: FutureBuilder<int>(
          future: action.process.process.exitCode,
          builder: (context, exitCode) {
            closeWidgetAfterDone(context, exitCode);
            return SizedBox(
              height: 40,
              child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 5),
                    ...[
                      if (action.infos != null)
                        AppIcon.fromInfos(
                          action.infos!,
                          iconSize: 20,
                          withRightSidePadding: false,
                        ),
                      Row(
                        children: [
                          Icon(
                            action.type?.winget.icon,
                            size: 15,
                          ),
                          actionTitle(localization),
                        ].withSpaceBetween(width: 5),
                      ),
                      outputField(exitCode, context),
                      buttonAtEnd(exitCode, context),
                    ].withSpaceBetween(width: 10),
                    const SizedBox(width: 5)
                  ]),
            );
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

  Widget buttonAtEnd(AsyncSnapshot<int> exitCode, BuildContext context) {
    AppLocalizations localization = AppLocalizations.of(context)!;
    if (exitCode.hasData) {
      if (exitCode.data == 0) {
        return button(FluentIcons.accept, localization.ok,
            () => closeActionWidget(context));
      } else {
        return button(FluentIcons.error, localization.ok,
            () => closeActionWidget(context));
      }
    } else {
      return button(FluentIcons.chrome_close, localization.endProcess, () {
        ProcessScheduler.instance.removeProcess(action.process.process);
        closeActionWidget(context);
      });
    }
  }

  Text actionTitle(AppLocalizations locale) {
    return Text(
      action.infos?.name?.value ?? action.process.command.join(' '),
      style: const TextStyle(fontWeight: FontWeight.bold),
    );
  }

  Text fallbackText(AppLocalizations locale) =>
      Text(action.output.isNotEmpty ? action.output.last : locale.waiting);

  void closeActionWidget(BuildContext context) {
    PackageActionsNotifier.of(context).remove(action);
  }

  void closeWidgetAfterDone(
      BuildContext context, AsyncSnapshot<int> snapshot) async {
    if (snapshot.connectionState == ConnectionState.done) {
      PackageActionsNotifier actions = PackageActionsNotifier.of(context);
      int exitCode = await action.process.process.exitCode;
      if (exitCode == 0) {
        Future.delayed(const Duration(seconds: 5))
            .then((value) => actions.remove(action));
      }
    }
  }

  Widget outputField(AsyncSnapshot<int> exitCode, BuildContext context) {
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
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 40),
            child: Center(
              child: SingleChildScrollView(
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
