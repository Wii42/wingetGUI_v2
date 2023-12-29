import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:winget_gui/helpers/extensions/string_extension.dart';

import 'github_api_file_info.dart';

class GithubApi {
  final String repository;
  final String owner;
  final Uri? path;

  const GithubApi({
    required this.repository,
    required this.owner,
    this.path,
  });

  factory GithubApi.wingetVersionManifest(
          {required String packageID, required String version}) =>
      GithubApi(
        repository: 'winget-pkgs',
        owner: 'microsoft',
        path: Uri.parse(
            'manifests/${idInitialLetter(packageID)}/${idAsPath(packageID)}/$version'),
      );

  factory GithubApi.wingetManifest({required String packageID}) => GithubApi(
        repository: 'winget-pkgs',
        owner: 'microsoft',
        path: Uri.parse(
            'manifests/${idInitialLetter(packageID)}/${idAsPath(packageID)}'),
      );

  factory GithubApi.wingetRepo(Uri path) => GithubApi(
        repository: 'winget-pkgs',
        owner: 'microsoft',
        path: path,
      );

  Uri get apiUri => Uri.parse(
      'https://api.github.com/repos/$owner/$repository/contents/${path?.path ?? ''}');

  Future<List<GithubApiFileInfo>> getFiles(
      {Future<List<GithubApiFileInfo>> Function()? onError}) async {
    if (kDebugMode) {
      print(apiUri);
    }
    Response response = await get(apiUri);
    if (response.statusCode == 200) {
      final List<GithubApiFileInfo> files = jsonDecode(response.body)
          .map<GithubApiFileInfo>((e) => GithubApiFileInfo.fromJson(e))
          .toList();
      return files;
    }
    if (onError != null) {
      return onError();
    }
    throw Exception(
        'Failed to load files from Github API: $apiUri ${response.statusCode} ${response.reasonPhrase} ${response.body}');
  }

  static String? idInitialLetter(String id) {
    return id.firstChar().toLowerCase();
  }

  static String? idAsPath(String id) {
    return id.replaceAll('.', '/');
  }
}
