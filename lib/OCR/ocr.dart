import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/Login/auth.dart';
import 'package:flutter_mobile_vision/flutter_mobile_vision.dart';
import 'ocr_text_detail.dart';

class OCR extends StatefulWidget {
  final BaseAuth auth;

  OCR({this.auth});

  @override
  _OCRState createState() => _OCRState();
}

class _OCRState extends State<OCR> {
  bool _torchOcr = false;
  bool _showTextOcr = true;
  List<OcrText> _textsOcr = [];

  @override
  void initState() {
    super.initState();
    FlutterMobileVision.start();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        primarySwatch: Colors.blue,
        buttonColor: Colors.blue,
      ),
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text("New Scan"),
          centerTitle: true,
        ),
        body: _getOcrScreen(context),
      ),
    );
  }

  Widget _getOcrScreen(BuildContext context) {
    List<Widget> items = [];

    items.add(new SwitchListTile(
      title: const Text('Show text:'),
      value: _showTextOcr,
      onChanged: (value) => setState(() => _showTextOcr = value),
    ));
    items.add(new SwitchListTile(
      title: const Text('Torch:'),
      value: _torchOcr,
      onChanged: (value) => setState(() => _torchOcr = value),
    ));

    items.add(
      new Padding(
        padding: const EdgeInsets.only(
          left: 18.0,
          right: 18.0,
          bottom: 12.0,
        ),
        child: new RaisedButton(
          onPressed: _read,
          child: new Text('READ!'),
        ),
      ),
    );

    items.addAll(
      ListTile.divideTiles(
        context: context,
        tiles: _textsOcr
            .map(
              (ocrText) =>
                  new OcrTextWidget(ocrText: ocrText, auth: widget.auth),
            )
            .toList(),
      ),
    );

    return new ListView(
      padding: const EdgeInsets.only(
        top: 12.0,
      ),
      children: items,
    );
  }

  /// OCR Method !!!
  Future<Null> _read() async {
    List<OcrText> texts = [];
    try {
      texts = await FlutterMobileVision.read(
        flash: _torchOcr,
        autoFocus: true,
        multiple: true,
        waitTap: true,
        showText: _showTextOcr,
        preview:
            FlutterMobileVision.getPreviewSizes(FlutterMobileVision.CAMERA_BACK)
                .elementAt(0),
        camera: FlutterMobileVision.CAMERA_BACK,
        fps: 10.0,
      );
    } on Exception {
      texts.add(new OcrText('Failed to recognize text.'));
    }

    if (!mounted) return;

    setState(() => _textsOcr = texts);
  }
}

class OcrTextWidget extends StatelessWidget {
  final OcrText ocrText;
  final BaseAuth auth;

  OcrTextWidget({this.ocrText, this.auth});

  @override
  Widget build(BuildContext context) {
    return new ListTile(
      leading: const Icon(Icons.title),
      title: new Text(ocrText.value),
      subtitle: new Text(ocrText.language),
      trailing: const Icon(Icons.arrow_forward),
      onTap: () => Navigator.of(context).push(
        new MaterialPageRoute(
          builder: (context) => new OcrTextDetail(ocrText: ocrText, auth: auth),
        ),
      ),
    );
  }
}
