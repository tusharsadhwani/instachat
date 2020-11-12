import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

Future<void> main() async {
  const clientID = "com.tusharsadhwani.instachat";
  const body = "username=tushar&password=password&grant_type=password";

  final String clientCredentials =
      const Base64Encoder().convert("$clientID:".codeUnits);

  print('Creds:$clientCredentials');

  final http.Response response =
      await http.post("http://localhost:8888/auth/token",
          headers: {
            "Content-Type": "application/x-www-form-urlencoded",
            "Authorization": "Basic $clientCredentials"
          },
          body: body);
  print(response.body);
}
