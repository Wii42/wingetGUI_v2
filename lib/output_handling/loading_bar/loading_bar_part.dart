import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/helpers/extensions/string_extension.dart';
import 'package:winget_gui/output_handling/output_part.dart';

class LoadingBarPart extends OutputPart {
  static const String progressBarKey = 'progressBar', restKey = 'rest';

  LoadingBarPart(super.lines);

  @override
  Future<Widget?> representation(BuildContext context) async {
    if (lines.isEmpty) {
      return null;
    }
    //return Column(children: [for (String line in lines) progressBar(line, context)]);
    return progressBar(lines.last, context);
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

  int numberOfFilledBars(String loadingBar){
    assert(loadingBar.containsOnlyProgressBarSymbols());

    int bars = 0;
    bool hasBars = true;
    while (hasBars && bars < loadingBar.length){
      hasBars = (loadingBar.codeUnitAt(bars) == '█'.codeUnits.single);
      bars++;
    }
    return bars;
  }

  double loadingBarValue(String loadingBar){
    assert(loadingBar.containsOnlyProgressBarSymbols());

    int totalBars = loadingBar.length;
    int numberOfFilled = numberOfFilledBars(loadingBar);
    return (numberOfFilled / totalBars) * 100;
  }

  Widget progressBar(String line, BuildContext context){
    Map<String, String> parts = separateLoadingBar(line);
    return Row(children: [ProgressBar(value: loadingBarValue(parts[progressBarKey]!),backgroundColor: FluentTheme.of(context).accentColor.withAlpha(50),), if(parts.containsKey(restKey))Text(parts[restKey]!)]);
  }
}
