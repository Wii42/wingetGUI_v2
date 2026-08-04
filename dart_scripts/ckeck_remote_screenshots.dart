import 'package:winget_core/winget_core.dart';
import 'package:winget_gui/server_interface/marti_clement_server_interface.dart';
import 'package:winget_gui/server_interface/server_interface.dart';

void main()async {
  ServerInterface serverInterface = MartiClientServerInterface();
  Map<String, PackageScreenshots> screenshots = await serverInterface.fetchPackageScreenshotsFromServer();
  print("Fetched ${screenshots.length} screenshots from server:");
  screenshots.entries.forEach(print);
  print("");
  print("Fetching invalid image urls from server...");
  List<Uri> invalidUrls = await serverInterface.fetchInvalidImageUrlsFromServer();
  print("Fetched ${invalidUrls.length} invalid image urls from server:");
  invalidUrls.forEach(print);

}