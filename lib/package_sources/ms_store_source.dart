import 'dart:ui';

import 'package:winget_gui/package_infos/package_infos_full.dart';

import 'microsoft_store_api/microsoft_store_manifest_api.dart';
import 'package_source.dart';

class MSStoreSource extends PackageSource {
  MSStoreSource(super.package);

  @override
  Future<PackageInfosFull> fetchInfos(Locale? guiLocale) async {
    if (package.id == null) {
      throw Exception('Package has no ID');
    }
    Map<String, dynamic> map = await api!.getJson();
    return PackageInfosFull.fromMSJson(
        file: map, locale: guiLocale, source: 'msstore');
  }

  @override
  Uri? get manifestUrl => api?.apiUri;

  MicrosoftStoreManifestApi? get api {
    if (package.id == null) {
      return null;
    }
    return MicrosoftStoreManifestApi(packageID: package.id!.value);
  }
}
