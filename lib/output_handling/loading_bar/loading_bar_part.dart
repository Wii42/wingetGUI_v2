import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/output_handling/output_part.dart';

class LoadingBarPart extends OutputPart {
  LoadingBarPart(super.lines);

  @override
  Widget representation() {
    return Column(children: [
      for (String line in lines) ProgressBar(value: _getPercentage(line))
    ]);
  }

  double _getPercentage(String line) {
    String percentage = line.trim().split(' ').last;
    if (percentage.endsWith('%')) {
      String value = percentage.split('%').first;
      num? number = num.tryParse(value);
      if (number != null) {
        return number.toDouble();
      }
    }
    return 0;
  }

  addLine(String line) {
    lines.add(line);
  }
}
