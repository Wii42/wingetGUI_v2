import 'dart:convert';

import 'package:http/http.dart';

void main()async {
  Response r = await post(Uri.parse("https://storeedgefd.dsx.mp.microsoft.com/v9.0/manifestSearch"), body: json.encode({
    "Query": {
      "KeyWord": "A",
      "MatchType": "Substring"
    }
  }), headers: {"Content-Type": "application/json"},);
  print(r.statusCode);
  print(r.body);
}