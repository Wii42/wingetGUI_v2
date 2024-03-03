import 'dart:convert';

import 'microsoft_store_api.dart';

class MicrosoftStoreManifestApi extends MicrosoftStoreApi {
  MicrosoftStoreManifestApi({required super.packageID});

  @override
  Uri get apiUri => Uri.parse(
      "https://storeedgefd.dsx.mp.microsoft.com/v9.0/packageManifests/$packageID");

  Future<Map<String, dynamic>> getJson() async {
    String response = await super.response();
    return json.decode(response);
  }
}
