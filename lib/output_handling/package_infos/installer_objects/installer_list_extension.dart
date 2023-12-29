import '../info.dart';
import 'installer.dart';

typedef Feature = Info? Function(Installer);

extension InstallerList on List<Installer> {
  List<Feature> minimalUniqueIdentifiers() {
    List<Feature> uniqueFeatures = [];
    for (Info? Function(Installer) feature in definingFeatures) {
      if (isFeatureEverywhereTheSame(feature)) continue;
      if (isFeatureUniqueIdentifier(feature)) {
        return [feature];
      }
    }
    return uniqueFeatures;
  }

  bool isFeatureUniqueIdentifier(Info? Function(Installer) feature) {
    List<dynamic> values = map<Info?>(feature).map((e) => e?.value).toList();
    return values.toSet().length == length;
  }

  bool isFeatureEverywhereTheSame(Info? Function(Installer) feature) {
    List<dynamic> values = map<Info?>(feature).map((e) => e?.value).toList();
    return values.toSet().length == 1;
  }

  List<Feature> get definingFeatures {
    return [
      (installer) => installer.architecture,
      (installer) => installer.type,
      (installer) => installer.locale,
      (installer) => installer.platform,
      (installer) => installer.minimumOSVersion,
      (installer) => installer.scope,
      (installer) => installer.elevationRequirement,
    ];
  }
}
