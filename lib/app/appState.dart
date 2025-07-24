import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class MyAppState extends ChangeNotifier {
  final dio = Dio();
  String pred = '-';

  Future<void> predict(List<List<dynamic>> matrix) async {
    try {
      final response = await dio.post(
        'https://mnist.zeabur.app/',
        data: {'matrix': matrix.toString()},
        options: Options(
          followRedirects: true,
          maxRedirects: 5,
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      pred = (response.statusCode == 200)
          ? response.data.toString()
          : "Error: ${response.statusCode}";
    } catch (e) {
      pred = "Network error: ${e.toString()}";
      print("Dio error: ${e.toString()}");
    }
    notifyListeners();
  }
}
