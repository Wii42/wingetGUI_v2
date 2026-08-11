import 'package:winget_core/winget_core.dart';
import 'package:winget_gui/server_interface/unigetui_server_interface.dart';
import 'package:winget_gui/server_interface/server_interface.dart';

void main() async {
  ServerInterface serverInterface = UniGetUIServerInterface();
  Map<String, PackageScreenshots> screenshots =
      await serverInterface.fetchPackageScreenshotsFromServer();
  print("Fetched ${screenshots.length} screenshots from server:");
  screenshots.entries.forEach(print);
}
