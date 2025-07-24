import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mnist/widget/paint.dart';
import 'package:provider/provider.dart';
import 'package:mnist/app/appState.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late List<List<int>> matrix;
  final List<Offset> points = [];
  final paintKey = GlobalKey();

  void clearCanvas() {
    setState(() {
      points.clear();
    });
  }

  Future<List<List<int>>> _getImageMatrix() async {
    final boundary =
        paintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      return List.generate(28, (_) => List.filled(28, 0));
    }

    final image = await boundary.toImage(pixelRatio: 1.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      return List.generate(28, (_) => List.filled(28, 0));
    }

    final imageBytes = byteData.buffer.asUint8List();
    final decodedImage = img.decodeImage(imageBytes);
    if (decodedImage == null) {
      return List.generate(28, (_) => List.filled(28, 0));
    }

    final grayImage = img.grayscale(decodedImage);
    final resizedImage = img.copyResize(grayImage, width: 28, height: 28);

    final matrix = List.generate(28, (_) => List.filled(28, 0));

    for (int y = 0; y < 28; y++) {
      for (int x = 0; x < 28; x++) {
        final pixel = resizedImage.getPixel(x, y);
        final grayValue = pixel.r as int;
        matrix[y][x] = grayValue;
      }
    }

    return matrix;
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Result: ${appState.pred}"),
            SizedBox(height: 20),
            Container(
              width: 224,
              height: 224,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey),
              ),
              child: RepaintBoundary(
                key: paintKey,
                child: GestureDetector(
                  onPanDown: (details) =>
                      setState(() => points.add(details.localPosition)),
                  onPanUpdate: (details) =>
                      setState(() => points.add(details.localPosition)),
                  onPanEnd: (details) => points.add(Offset.zero),
                  child: CustomPaint(
                    painter: MyPaint(points: points),
                    child: Container(),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                matrix = await _getImageMatrix();
                await appState.predict(matrix);
              },
              child: Text('Predict'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                appState.pred = '-';
                clearCanvas();
              },
              child: Text('Clear'),
            ),
          ],
        ),
      ),
    );
  }
}
