import 'dart:convert';

import 'package:http/http.dart';
import 'package:winget_gui/helpers/log_stream.dart';

void main() async {
  Logger log = Logger('Post Test');
  Response r = await post(
    Uri.parse("https://storeedgefd.dsx.mp.microsoft.com/v9.0/manifestSearch"),
    body: json.encode({
      "Query": {"KeyWord": "A", "MatchType": "Substring"}
    }),
    headers: {"Content-Type": "application/json"},
  );
  log.info(r.statusCode.toString());
  log.info(r.body);
}
