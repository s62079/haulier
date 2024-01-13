import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

class _Data {
  static String uri = 'c3114p2-default-rtdb.asia-southeast1.firebasedatabase.app';
  static Map<String, String> headers = {'Content-Type': 'application/json'};

  static Future<String> addUser(Map<String, String> data) async {
    // https://stackoverflow.com/questions/61276701
    final queryFilter = {
      'orderBy': '"username"',
      'equalTo': '"${data['username']}"',
    };
    final urlGet = Uri.https(uri, 'users.json', queryFilter);
    Response response = await get(urlGet);
    Map result = json.decode(response.body);

    if (response.statusCode == 200 && result.isEmpty) {
      final url = Uri.https(uri, 'users.json');
      final String body = json.encode(data);
      response = await post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('DEBUG: $data added');
        }
        return 'ok';
      }
    } else {
      return 'exist';
    }
    if (kDebugMode) {
      print('DEBUG: error');
    }
    return 'error';
  }
}
