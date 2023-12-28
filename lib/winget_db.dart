import 'package:winget_gui/winget_commands.dart';
import 'package:winget_gui/winget_process/winget_process.dart';

void wingetDB() async {
  WingetProcess winget = await WingetProcess.runWinget(Winget.updates);
  winget.
}