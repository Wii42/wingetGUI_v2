abstract class PackageLocalizer{


  String get userScope;

  String get machineScope;

  String? infoKey(String key);
  String? infoTitle(String key);

  String returnResponse(String name);

  String installMode(String key);

  String upgradeBehavior(String key);
}