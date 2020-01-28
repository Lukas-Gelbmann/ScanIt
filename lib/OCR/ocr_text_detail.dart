import 'package:flutter/material.dart';
import 'package:flutter_mobile_vision/flutter_mobile_vision.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OcrTextDetail extends StatefulWidget {
  final OcrText ocrText;

  OcrTextDetail(this.ocrText);

  @override
  _OcrTextDetailState createState() => new _OcrTextDetailState();
}

class _OcrTextDetailState extends State<OcrTextDetail> {
  TextEditingController textController;
  TextEditingController headingController;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    textController.dispose();
    headingController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    textController =
        TextEditingController(text: widget.ocrText.value.toString());
    headingController = TextEditingController(text: '');
  }

  @override
  Widget build(BuildContext context) {
    print("ocr_text_detail started");
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Face Details'),
      ),
      body: new ListView(
        children: <Widget>[
          new ListTile(
            subtitle: new TextFormField(
              controller: headingController,
            ),
            title: const Text('Title'),
          ),
          new ListTile(
            subtitle: new TextFormField(
              maxLines: 20,
              controller: textController,
            ),
            title: const Text('Text'),
          ),
          new RaisedButton(
            onPressed: () async {
              _save();
            },
            child: new Text('SAVE'),
          )
        ],
      ),
    );
  }

  Future<Null> _save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int counter = (prefs.getInt('counter') ?? 0) + 1;
    List<String> list = new List<String>();
    list.add(headingController.text.toString());
    list.add(textController.text.toString());
    print('$list');
    await prefs.setString('$counter heading', headingController.text.toString());
    await prefs.setString('$counter text', textController.text.toString());
    await prefs.setInt('counter', counter);
    print('Saved on position $counter ');
    Navigator.pop(context);
  }
}
