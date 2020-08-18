import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(ItomakiwebApp());
}

class ItomakiwebApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Itomakiweb!',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ItomakiwebHomePage(title: 'Bookmarkit! List'),
      routes: {
        '/': (context) => ItomakiwebHomePage(title: 'Bookmarkit! List'),
        '/bookmarks/': (context) => BookmarkHomePage(),
        '/bookmarks/new': (context) =>
            BookmarkNewPage(title: 'Bookmarkit! New'),
      },
    );
  }
}

class ItomakiwebHomePage extends StatefulWidget {
  ItomakiwebHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ItomakiwebHomePageState createState() => _ItomakiwebHomePageState();
}

class _ItomakiwebHomePageState extends State<ItomakiwebHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          InkWell(
              onTap: () {
                Navigator.of(context).pushNamed("/bookmarks/new");
              },
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(Icons.add),
              ))
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  FlatButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed("/bookmarks/");
                      },
                      child: Text("Bookmark"))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class BookmarkHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bookmark List"),
        actions: [
          InkWell(
              onTap: () {
                Navigator.of(context).pushNamed("/bookmarks/new");
              },
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(Icons.add),
              ))
        ],
      ),
      body: Center(
        child: BookmarkList(),
      ),
    );
  }
}

class BookmarkShowPage extends StatefulWidget {
  BookmarkShowPage({Key key, this.title, @required this.documentId})
      : super(key: key);

  final String title;
  final String documentId;

  @override
  _BookmarkShowPageState createState() => _BookmarkShowPageState();
}

class _BookmarkShowPageState extends State<BookmarkShowPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: new StreamBuilder(
            stream: Firestore.instance
                .collection('bookmarks')
                .document(widget.documentId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return new Text("Loading");
              }
              var bookmarkDocument = snapshot.data;
              return BookmarkViewer2(bookmarkItem: bookmarkDocument);
              // return new Text(bookmarkDocument["title"]);
            }));
  }
}

class BookmarkNewPage extends StatefulWidget {
  BookmarkNewPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _BookmarkNewPageState createState() => _BookmarkNewPageState();
}

class _BookmarkNewPageState extends State<BookmarkNewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: BookmarkViewer(),
    );
  }
}

class BookmarkList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('bookmarks').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return new Text('Loading...');
          default:
            return new ListView(
              children:
                  snapshot.data.documents.map((DocumentSnapshot document) {
                return new ListTile(
                  title: new Text(document['title']),
                  subtitle: new Text(document['titleShort']),
                  onTap: () {
                    // TODO think about reload
                    var routeName = "/bookmarks/" + document.documentID;
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            settings: RouteSettings(name: routeName),
                            builder: (context) => BookmarkShowPage(
                                  documentId: document.documentID,
                                )));
                  },
                );
              }).toList(),
            );
        }
      },
    );
  }
}

class BookmarkViewer extends StatefulWidget {
  @override
  BookmarkViewerState createState() => BookmarkViewerState();
}

class BookmarkViewerState extends State<BookmarkViewer> {
  final _formKey = GlobalKey<FormState>();
  final _formKeyForDialog = GlobalKey<FormState>();
  Map<String, dynamic> _bookmarkItem = getBookmarkItem();
  bool _doEdit = true;

  @override
  Widget build(BuildContext context) {
    // GridView.countはレスポンシブ対応しづらいので使わない
    var cols = [];
    for (var i = 0; i < _bookmarkItem['sizeY']; i++) {
      var rowFields = <Widget>[];
      for (var j = 0; j < _bookmarkItem['sizeX']; j++) {
        var count = i * _bookmarkItem['sizeX'] + j;
        var bookmarkBaseItem = _bookmarkItem['bookmarkBaseItems'][count];
        rowFields.add(Expanded(
            child: InkWell(
          onTap: () {
            if (_doEdit) {
              showDialog(
                  context: context,
                  builder: (_) {
                    return AlertDialog(
                      title: Text("Edit"),
                      content: Form(
                        key: _formKeyForDialog,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            TextFormField(
                              initialValue: bookmarkBaseItem['url'],
                              decoration: const InputDecoration(
                                icon: Icon(Icons.link),
                                labelText: 'URL',
                                hintText: 'URLを入力してください',
                                border: OutlineInputBorder(),
                              ),
                              autovalidate: false,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'URLを入力してください';
                                }

                                return null;
                              },
                              onSaved: (value) {
                                setState(() {
                                  _bookmarkItem['bookmarkBaseItems'][count]
                                      ['url'] = value;
                                });
                              },
                            ),
                            TextFormField(
                              initialValue: bookmarkBaseItem['title'],
                              decoration: const InputDecoration(
                                icon: Icon(Icons.title),
                                border: OutlineInputBorder(),
                                labelText: 'タイトル',
                                hintText: 'タイトルを入力してください',
                              ),
                              autovalidate: false,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'タイトルを入力してください';
                                }

                                return null;
                              },
                              onSaved: (value) {
                                setState(() {
                                  _bookmarkItem['bookmarkBaseItems'][count]
                                      ['title'] = value;
                                });
                              },
                            ),
                            TextFormField(
                              initialValue: bookmarkBaseItem['icon'],
                              decoration: const InputDecoration(
                                icon: Icon(Icons.bookmark),
                                border: OutlineInputBorder(),
                                labelText: 'アイコンURL',
                                hintText: 'アイコンURLを入力してください',
                              ),
                              autovalidate: false,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'アイコンURLを入力してください';
                                }

                                return null;
                              },
                              onSaved: (value) {
                                setState(() {
                                  _bookmarkItem['bookmarkBaseItems'][count]
                                      ['icon'] = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        FlatButton(
                          child: Text("save"),
                          onPressed: () {
                            // validate success
                            if (_formKeyForDialog.currentState.validate()) {
                              // 以下メソッド呼び出し後、onSavedが呼び出される
                              _formKeyForDialog.currentState.save();
                            }
                            Navigator.pop(context);
                          },
                        )
                      ],
                    );
                  });
            } else {
              launch("${bookmarkBaseItem['url']}");
            }
          },
          child: Column(
            children: [
              Image.network(
                "${bookmarkBaseItem['icon']}",
                // fit: BoxFit.cover,
                // width: 40,
                height: 40,
              ),
              Text("${bookmarkBaseItem['title']}"),
            ],
          ),
        )));
      }
      cols.add(Expanded(
          child: Row(
        children: rowFields,
      )));
    }
    cols.add(Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            initialValue: _bookmarkItem['icon'],
            decoration: const InputDecoration(
              icon: Icon(Icons.link),
              labelText: 'アイコンURL',
              hintText: 'アイコンURLを入力してください',
              border: OutlineInputBorder(),
            ),
            autovalidate: false,
            validator: (value) {
              if (value.isEmpty) {
                return 'アイコンURLを入力してください';
              }

              return null;
            },
            onSaved: (value) {
              _bookmarkItem['icon'] = value;
            },
          ),
          TextFormField(
            decoration: const InputDecoration(
              icon: Icon(Icons.title),
              border: OutlineInputBorder(),
              labelText: 'タイトル',
              hintText: 'タイトルを入力してください',
            ),
            initialValue: _bookmarkItem['title'],
            autovalidate: false,
            validator: (value) {
              if (value.isEmpty) {
                return 'タイトルを入力してください';
              }

              return null;
            },
            onSaved: (value) {
              _bookmarkItem['title'] = value;
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: RaisedButton(
              onPressed: () {
                // validate success
                if (_formKey.currentState.validate()) {
                  // 以下メソッド呼び出し後、onSavedが呼び出される
                  _formKey.currentState.save();
                  Firestore.instance
                      .collection('bookmarks')
                      .document()
                      .setData(_bookmarkItem);
                }
              },
              child: Text('情報を登録する'),
            ),
          ),
        ],
      ),
    ));

    return Column(
      children: cols,
    );
  }
}

class BookmarkViewer2 extends StatefulWidget {
  BookmarkViewer2({Key key, @required this.bookmarkItem}) : super(key: key);

  final Map<String, dynamic> bookmarkItem;

  @override
  BookmarkViewerState2 createState() => BookmarkViewerState2();
}

class BookmarkViewerState2 extends State<BookmarkViewer2> {
  @override
  Widget build(BuildContext context) {
    // GridView.countはレスポンシブ対応しづらいので使わない
    var cols = [];
    for (var i = 0; i < widget.bookmarkItem['sizeY']; i++) {
      var rowFields = <Widget>[];
      for (var j = 0; j < widget.bookmarkItem['sizeX']; j++) {
        var count = i * widget.bookmarkItem['sizeX'] + j;
        var bookmarkBaseItem = widget.bookmarkItem['bookmarkBaseItems'][count];
        rowFields.add(Expanded(
            child: InkWell(
          onTap: () {
            launch("${bookmarkBaseItem['url']}");
          },
          child: Column(
            children: [
              Image.network(
                "${bookmarkBaseItem['icon']}",
                // fit: BoxFit.cover,
                // width: 40,
                height: 40,
              ),
              Text("${bookmarkBaseItem['title']}"),
            ],
          ),
        )));
      }
      cols.add(Expanded(
          child: Row(
        children: rowFields,
      )));
    }

    return Column(
      children: cols,
    );
  }
}

class BookmarkEditor extends StatefulWidget {
  @override
  BookmarkEditorState createState() => BookmarkEditorState();
}

class BookmarkEditorState extends State<BookmarkEditor> {
  final _formKey = GlobalKey<FormState>();
  String _url = '';
  String _titleShort = '';

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            decoration: const InputDecoration(
              icon: Icon(Icons.link),
              labelText: 'URL',
              hintText: 'URLを入力してください',
              border: OutlineInputBorder(),
            ),
            autovalidate: false,
            validator: (value) {
              if (value.isEmpty) {
                return 'URLを入力してください';
              }

              return null;
            },
            onSaved: (value) {
              this._url = value;
            },
          ),
          TextFormField(
            decoration: const InputDecoration(
              icon: Icon(Icons.title),
              border: OutlineInputBorder(),
              labelText: 'タイトル',
              hintText: 'タイトルを入力してください',
            ),
            initialValue: "test",
            autovalidate: false,
            validator: (value) {
              if (value.isEmpty) {
                return 'タイトルを入力してください';
              }

              return null;
            },
            onSaved: (value) {
              this._titleShort = value;
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: RaisedButton(
              onPressed: () {
                // validate success
                if (_formKey.currentState.validate()) {
                  // 以下メソッド呼び出し後、onSavedが呼び出される
                  this._formKey.currentState.save();
                  Firestore.instance.collection('books').document().setData({
                    'url': this._url,
                    'title': this._titleShort,
                    /*
                      'url': '$_url',
                      'title': '$_titleShort',
                      */
                  });
                }
              },
              child: Text('情報を登録する'),
            ),
          ),
        ],
      ),
    );
  }
}

Map<String, dynamic> getBookmarkItem() {
  var bookmarkItem = getBookmarkBaseItem();
  bookmarkItem['sizeX'] = 4;
  bookmarkItem['sizeY'] = 6;
  final bookmarkMaxCount = bookmarkItem['sizeX'] * bookmarkItem['sizeY'];
  bookmarkItem['bookmarkBaseItems'] = [];
  for (var i = 0; i < bookmarkMaxCount; i++) {
    bookmarkItem['bookmarkBaseItems'].add(getBookmarkBaseItem());
  }

  return bookmarkItem;
}

Map<String, dynamic> getBookmarkBaseItem() {
  return {
    'sizeX': 1,
    'sizeY': 1,
    'clickCount': 0,
    'title': 'ヘミノ',
    'titleShort': 'Hemino',
    'icon': 'https://hemino.com/2b.png',
    'url': 'https://hemino.com/',
    'body': '', // ヘミノ：興味と知識の集約サイト
    'refShortcutIcon': '',
    'refAppleTouchIcon': '',
    'refOgType': '', // website or article
    'refOgUrl': '',
    'refOgTitle': '',
    'refOgDescrption': '',
    'refOgSiteName': '',
    'refOgLocale': '',
    'refOgImage': '',
  };
}
