import 'dart:ui';

import 'package:winget_gui/package_sources/package_source.dart';

import '../output_handling/package_infos/package_infos_full.dart';
import 'microsoft_store_api/microsoft_store_manifest_api.dart';

class MSStoreSource extends PackageSource {
  MSStoreSource(super.package);
  @override
  Future<PackageInfosFull> fetchInfos(Locale? guiLocale) async {
    String? packageID = package.id?.value;
    if (packageID == null) {
      throw Exception('Package has no ID');
    }
    MicrosoftStoreManifestApi api =
        MicrosoftStoreManifestApi(packageID: packageID);
    Map<String, dynamic> map = await api.getJson();
    return PackageInfosFull.fromMSJson(file: map, locale: guiLocale, infosSource: api.apiUri, source: 'msstore');
  }
}
