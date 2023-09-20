import 'dart:async';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/helpers/extensions/string_extension.dart';
import 'package:winget_gui/output_handling/loading_bar/loading_bar_builder.dart';
import 'package:winget_gui/output_handling/output_builder.dart';
import 'package:winget_gui/output_handling/output_parser.dart';

typedef LoadingBar = ({double value, String? text});

class LoadingBarParser extends OutputParser {
  static const String progressBarKey = 'progressBar', restKey = 'rest';

  LoadingBarParser(super.lines);

  @override
  FutureOr<OutputBuilder>? parse(AppLocalizations wingetLocale) {
    if (lines.isEmpty) {
      return null;
    }
    return LoadingBarBuilder(progressBar(lines.last));
  }

  Map<String, String> separateLoadingBar(String line) {
    String trimmed = line.trim();
    int splitIndex = trimmed.indexOf(' ');
    String progressBarPart =
        hasRest(splitIndex) ? trimmed.substring(0, splitIndex) : trimmed;

    assert(progressBarPart.containsOnlyProgressBarSymbols());
    String rest = hasRest(splitIndex) ? trimmed.substring(splitIndex) : '';
    return {progressBarKey: progressBarPart, restKey: rest};
  }

  bool hasRest(int splitIndex) {
    return splitIndex >= 0;
  }

  int numberOfFilledBars(String loadingBar) {
    assert(loadingBar.containsOnlyProgressBarSymbols());

    int bars = 0;
    bool hasBars = true;
    while (hasBars && bars < loadingBar.length) {
      hasBars = (loadingBar.codeUnitAt(bars) == '█'.codeUnits.single);
      bars++;
    }
    return bars;
  }

  double loadingBarValue(String loadingBar) {
    assert(loadingBar.containsOnlyProgressBarSymbols());

    int totalBars = loadingBar.length;
    int numberOfFilled = numberOfFilledBars(loadingBar);
    return (numberOfFilled / totalBars) * 100;
  }

  LoadingBar progressBar(String line) {
    Map<String, String> parts = separateLoadingBar(line);
    return (
      text: parts[restKey],
      value: loadingBarValue(parts[progressBarKey]!)
    );
  }
}
