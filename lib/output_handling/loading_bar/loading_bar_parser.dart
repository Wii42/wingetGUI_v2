import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/helpers/extensions/string_extension.dart';
import 'package:winget_gui/output_handling/loading_bar/loading_bar_builder.dart';
import 'package:winget_gui/output_handling/output_parser.dart';
import 'package:winget_gui/output_handling/parsed_output.dart';

class LoadingBarParser extends OutputParser {
  static const String progressBarKey = 'progressBar', restKey = 'rest';

  LoadingBarParser(super.lines);

  @override
  ParsedLoadingBars parse(AppLocalizations wingetLocale) {
    if (lines.isEmpty) {
      return ParsedLoadingBars([]);
    }
    return ParsedLoadingBars(lines.map(progressBar).toList(),
        isLastCutOff: isLastCutOff());
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
    return LoadingBar(
        text: parts[restKey], value: loadingBarValue(parts[progressBarKey]!));
  }

  bool isLastCutOff() {
    if (lines.length < 2) {
      return false;
    }
    Map<String, String> lastLine = separateLoadingBar(lines.last);
    String lastProgressBar = lastLine[progressBarKey]!;
    String? lastRest = lastLine[restKey];

    Map<String, String> secondLastLine =
        separateLoadingBar(lines[lines.length - 2]);
    String secondLastProgressBar = secondLastLine[progressBarKey]!;
    String? secondLastRest = secondLastLine[restKey];

    return lastProgressBar.length < secondLastProgressBar.length ||
        (lastRest == null) != (secondLastRest == null);
  }
}

class ParsedLoadingBars extends ParsedOutput {
  List<LoadingBar> loadingBars;
  bool isLastCutOff;

  ParsedLoadingBars(this.loadingBars, {this.isLastCutOff = false});

  @override
  Widget? widgetRepresentation() {
    if (loadingBars.isEmpty) {
      return null;
    }
    return LoadingBarBuilder(
        isLastCutOff ? loadingBars[loadingBars.length - 2] : loadingBars.last);
  }
}

class LoadingBar {
  double value;
  String? text;

  LoadingBar({required this.value, this.text});
}
