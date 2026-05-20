import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/sign.dart';

class MockSignLoader {
  static const assetPath = 'assets/data/mock-signs.json';

  static Future<List<Sign>> loadSigns() async {
    final jsonText = await rootBundle.loadString(assetPath);
    final jsonList = jsonDecode(jsonText) as List<dynamic>;
    return jsonList
        .map((entry) => Sign.fromJson(entry as Map<String, dynamic>))
        .toList();
  }
}
