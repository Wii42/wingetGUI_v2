import 'dart:convert';

import 'package:http/http.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:winget_gui/helpers/log_stream.dart';

import '../../output_handling/package_infos/package_id.dart';
import '../no_internet_exception.dart';
import 'github_load_exception.dart';
import 'github_rate_limit_exception.dart';
import 'github_api_file_info.dart';

class GithubApi {
  late final Logger log;

  final String repository;
  final String owner;
  final List<String> pathFragments;

  GithubApi({
    required this.repository,
    required this.owner,
    this.pathFragments = const [],
  }) {
    log = Logger(this);
  }

  factory GithubApi.wingetVersionManifest(
          {required PackageId packageID, required String version}) =>
      GithubApi(
        repository: 'winget-pkgs',
        owner: 'microsoft',
        pathFragments: [
          'manifests',
          packageID.initialLetter!,
          ...packageID.allParts,
          version
        ],
      );

  factory GithubApi.wingetManifest({required PackageId packageId}) => GithubApi(
        repository: 'winget-pkgs',
        owner: 'microsoft',
        pathFragments: [
          'manifests',
          packageId.initialLetter!,
          ...packageId.allParts
        ],
      );

  factory GithubApi.wingetRepo(List<String> pathFragments) => GithubApi(
        repository: 'winget-pkgs',
        owner: 'microsoft',
        pathFragments: pathFragments,
      );

  Uri get apiUri => Uri(
      scheme: 'https',
      host: 'api.github.com',
      pathSegments: ['repos', owner, repository, 'contents', ...pathFragments]);

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
    if (response.statusCode == 403 &&
        response.reasonPhrase == 'rate limit exceeded') {
      throw GithubRateLimitException.fromJson(
          url: apiUri,
          statusCode: response.statusCode,
          reasonPhrase: response.reasonPhrase!,
          jsonBody: response.body);
    }
    throw GithubLoadException(
        url: apiUri,
        statusCode: response.statusCode,
        reasonPhrase: response.reasonPhrase,
        responseBody: response.body);
  }
}
