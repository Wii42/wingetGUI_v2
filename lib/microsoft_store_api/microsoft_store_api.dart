import 'package:http/http.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../github_api/github_api.dart';
import '../helpers/log_stream.dart';

abstract class MicrosoftStoreApi {
  late final Logger log;
  String packageID;

  MicrosoftStoreApi({required this.packageID}) {
    log = Logger(this);
  }

  Uri get apiUri;

  Future<String> response() async {
    log.info('Fetching manifest from $apiUri');
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
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch manifest from $apiUri');
    }
    return response.body;
  }
}
