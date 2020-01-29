import 'dart:async';
import 'model.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../OCR/ocr.dart';
import 'package:flutter_firebase_auth/Login/auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomePage extends StatefulWidget {
  final BaseAuth auth;
  final VoidCallback onSignedOut;

  HomePage({Key key, this.auth, this.onSignedOut});

  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ScanIt'),
        centerTitle: true,
        actions: <Widget>[
          new FlatButton(
              onPressed: _signOut,
              child: new Text('Log out',
                  style: new TextStyle(fontSize: 17.0, color: Colors.white)))
        ],

      ),
      body: FutureBuilder<List>(
        future: Services.getEntries(widget),
        initialData: List(),
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (_, int position) {
                    final item = snapshot.data[position];
                    PopupMenuItem(
                      value: item,
                      child: Text("Delete"),
                    );
                    return Card(
                      child: ListTile(
                        title: Text(item.heading),
                        subtitle: Text(item.text),
                        //onTap: () => share(context, item),
                        //onLongPress: () => {remove(item)},
                        trailing: PopupMenuButton(
                          onSelected: _onSelected,
                          icon: Icon(Icons.menu),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: {2, item},
                              child: Text("Share"),
                            ),
                            PopupMenuItem(
                              value: {1, item},
                              child: Text("Delete"),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              : Center(
                  child: CircularProgressIndicator(),
                );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Add",
        child: Icon(Icons.add),
        onPressed: () {
          print("Clicked");
          Navigator.push(
            context,
            new MaterialPageRoute(builder: (context) => new OCR(auth: widget.auth)),
          );
        },
      ),
    );
  }

  void _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
      Fluttertoast.showToast(
          msg: "Logged out",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1);
    } catch (e) {
      print(e);
    }
  }

  share(BuildContext context, Entry entry) {
    final RenderBox box = context.findRenderObject();
    Share.share("${entry.heading}:\n${entry.text}",
        subject: entry.text,
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }

  remove(item) async {
    print('remove');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String uid = await widget.auth.currentUser();
    int counter = (prefs.getInt('counter $uid') ?? 0);
    for (int i = 1; i <= counter; i++) {
      if (prefs.getString('$i text $uid') == item.text) {
        prefs.remove('$i heading $uid');
        prefs.remove('$i text $uid');
        break;
      }
    }
    setState(() {});
  }

  void _onSelected(Set value) {
    if (value.elementAt(0) == 1) {
      remove(value.elementAt(1));
    } else {
      share(context, value.elementAt(1));
    }
  }
}

class Services {

  static Future<List<Entry>> getEntries(widget) async {
    List<Entry> entries = List<Entry>();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String uid = await widget.auth.currentUser();

    int counter = (prefs.getInt('counter $uid') ?? 0);
    for (int i = 1; i <= counter; i++) {
      if (prefs.getString('$i text $uid') != null) {
        entries.add(new Entry(
            heading: prefs.getString('$i heading $uid'),
            text: prefs.getString('$i text $uid')));
      }
    }
    print('Loaded');
    return entries;
  }
}
