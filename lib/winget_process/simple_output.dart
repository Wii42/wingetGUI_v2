import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/winget_process/winget_process.dart';
import '../winget_commands.dart';
import './process_output.dart';

class SimpleOutput extends ProcessOutput {
  const SimpleOutput({super.key, required super.process});
  factory SimpleOutput.fromCommand(List<String> command, {String? titleInput}) {
    return SimpleOutput(process: WingetProcess.fromCommand(command));
  }
  factory SimpleOutput.fromWinget(Winget winget) {
    return SimpleOutput(process: WingetProcess.fromWinget(winget));
  }

  @override
  Widget buildPage(
      AsyncSnapshot<List<String>> streamSnapshot, BuildContext context) {
    return Column(children: outputList(streamSnapshot, context));
  }
}
