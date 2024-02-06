import 'dart:convert';

import 'package:http/http.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:winget_gui/helpers/extensions/string_extension.dart';

import '../helpers/log_stream.dart';
import 'github_api_file_info.dart';

class GithubApi {
  late final Logger log;

  final String repository;
  final String owner;
  final Uri? path;

  GithubApi({
    required this.repository,
    required this.owner,
    this.path,
  }) {
    log = Logger(this);
  }

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
    log.info('Fetching files from $apiUri');
    Response response;
    try {
      response = await get(apiUri);
    } catch (e) {
      if (e.runtimeType.toString() == '_ClientSocketException' &&
          e.toString().startsWith(
              'ClientException with SocketException: Failed host lookup:')) {
        bool hasInternet = await InternetConnectionChecker().hasConnection;
        if (!hasInternet) {
          throw NoInternetException();
        }
      }
      rethrow;
    }
    if (response.statusCode == 200) {
      final List<GithubApiFileInfo> files = jsonDecode(response.body)
          .map<GithubApiFileInfo>((e) => GithubApiFileInfo.fromJson(e))
          .toList();
      return files;
    }
    if (onError != null) {
      return onError();
    }
    throw GithubLoadException(
        url: apiUri,
        statusCode: response.statusCode,
        reasonPhrase: response.reasonPhrase,
        responseBody: response.body);
  }

  static String? idInitialLetter(String id) {
    return id.firstChar().toLowerCase();
  }

  static String? idAsPath(String id) {
    return id.replaceAll('.', '/');
  }
}

class GithubLoadException implements Exception {
  Uri url;
  int statusCode;
  String? reasonPhrase;
  String? responseBody;

  GithubLoadException(
      {required this.url,
      required this.statusCode,
      this.reasonPhrase,
      this.responseBody});

  @override
  String toString() {
    return [
      'Failed to load files from Github API: $url',
      'status code: $statusCode',
      if (reasonPhrase != null) 'reason: $reasonPhrase',
      if (responseBody != null) 'response body: $responseBody'
    ].join(', ');
  }
}

class NoInternetException implements Exception {
  String? message;
  NoInternetException([message]);
  @override
  String toString() {
    if (message == null) return "No Internet Connection";
    return "No Internet Connection: $message";
  }
}
