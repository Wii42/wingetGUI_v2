import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/content/process_output.dart';

class SimpleOutput extends ProcessOutput {
  const SimpleOutput({super.key, required super.process});

  @override
  Widget buildPage(
      AsyncSnapshot<List<String>> streamSnapshot, BuildContext context) {
    return Column(children: outputList(streamSnapshot, context));
  }
}
