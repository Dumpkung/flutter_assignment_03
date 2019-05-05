import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(MyApp());

//HexColorClass
class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Todostate(title: 'Flutter Demo Home Page'),
    );
  }
}

class Todostate extends StatefulWidget {
  Todostate({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _TodoListScreenPage createState() => _TodoListScreenPage();
}

class _TodoListScreenPage extends State<Todostate> {
  Widget _undochangetodone(BuildContext context, DocumentSnapshot document) {
    return (document['done'] == 0)
        ? ListTile(
            title: Text(document['title']),
            trailing: Checkbox(
              value: false,
              // value: document['done'],
              // onChanged: (bool value) {
              //   FirestoreUtils.update(document.documentID, value);
              // },
              onChanged: (val) {
                Firestore.instance.runTransaction((Transaction tran) async {
                  DocumentSnapshot table = await tran.get(document.reference);
                  if (table.exists)
                    await tran.update(table.reference, {
                      'done': 1,
                    });
                });
              },
            ),
          )
        : Column();
  }

  Widget _unCompleteItem(BuildContext context) {
    var list;
    list = Center(
      child: Text(
        "No Data Found..",
        textAlign: TextAlign.center,
      ),
    );
    return StreamBuilder(
      stream: Firestore.instance.collection('todo').snapshots(),
      builder: (context, snapshot) {
        int check = 0;
        int lenghofvalue = snapshot.data.documents.length;
        for (var i = 0; i < lenghofvalue; i++) {
          if (snapshot.data.documents[i]['done'] == 0) {
            check += 1;
          }
        }
        if (check == 0) {
          return list;
        } else {
          return ListView.builder(
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) =>
                _undochangetodone(context, snapshot.data.documents[index]),
          );
        }
      },
    );
  }

  Widget _donechangetoundo(BuildContext context, DocumentSnapshot document) {
    if (document['done'] == 1) {
      return ListTile(
        title: Text(document['title']),
        trailing: Checkbox(
          value: true,
          onChanged: (val) {
            Firestore.instance.runTransaction((Transaction tran) async {
              DocumentSnapshot table = await tran.get(document.reference);
              if (table.exists)
                await tran.update(table.reference, {
                  'done': 0,
                });
            });
          },
        ),
      );
    } else {
      return Column();
    }
  }

  Widget _completeItem(BuildContext context) {
    var list;
    list = Center(
      child: Text(
        "No Data Found..",
        textAlign: TextAlign.center,
      ),
    );
    return StreamBuilder(
      stream: Firestore.instance.collection('todo').snapshots(),
      builder: (context, snapshot) {
        int havedata = 0;
        int lenghofvalue = snapshot.data.documents.length;
        for (var i = 0; i < lenghofvalue; i++) {
          if (snapshot.data.documents[i]['done'] == 1) {
            havedata += 1;
          }
        }
        if (havedata == 0) {
          return list;
        } else {
          return ListView.builder(
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) =>
                _donechangetoundo(context, snapshot.data.documents[index]),
          );
        }
      },
    );
  }

  void _addItem() async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => AddItempage()));
  }

  Future _delete() async {
    final QuerySnapshot result =
        await Firestore.instance.collection('todo').getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    for (var i = 0; i < documents.length; i++) {
      if (documents[i]['done'] == 1) {
        Firestore.instance
            .collection('todo')
            .document(documents[i].documentID)
            .delete();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          bottomNavigationBar: Container(
            color: HexColor("ffdae9"),
            child: TabBar(
              indicatorColor: Colors.white,
              tabs: <Widget>[
                Tab(
                  icon: Icon(Icons.format_list_bulleted),
                  text: "Task",
                ),
                Tab(
                  icon: Icon(Icons.done_all),
                  text: "Completed",
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              new Scaffold(
                appBar: AppBar(
                  title: Text("Todo"),
                  backgroundColor: HexColor("ffdae9"),
                  actions: <Widget>[
                    new IconButton(
                      icon: new Icon(Icons.add),
                      color: Colors.white,
                      onPressed: _addItem,
                    )
                  ],
                ),
                body: _unCompleteItem(context),
              ),
              new Scaffold(
                  appBar: AppBar(
                    title: Text("Todo"),
                    backgroundColor: HexColor("ffdae9"),
                    actions: <Widget>[
                      new IconButton(
                        icon: new Icon(Icons.delete),
                        color: Colors.white,
                        onPressed: _delete,
                      )
                    ],
                  ),
                  body: _completeItem(context)),
            ],
          ),
        ));
  }
}

class AddItempage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _AddItemState();
}

class _AddItemState extends State<AddItempage> {
  final _tdController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  // TodoProvider dbget = TodoProvider();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("New Subject"),
          backgroundColor: HexColor("ffdae9"),
        ),
        body: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: "Subject"),
                  controller: _tdController,
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Please fill subject";
                    }
                  },
                  onSaved: (value) => print(value),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                        child: RaisedButton(
                            child: Text("Save"),
                            onPressed: () {
                              if (!_formKey.currentState.validate()) {
                                print("Please fill Subject");
                              } else {
                                Firestore.instance.runTransaction(
                                    (Transaction transaction) async {
                                  CollectionReference reference =
                                      Firestore.instance.collection('todo');

                                  await reference.add(
                                      {"title": _tdController.text, "done": 0});
                                  _tdController.clear();
                                });
                                Navigator.pop(context);
                              }
                            }))
                  ],
                )
              ],
            )));
  }

  @override
  void dispose() {
    _tdController.dispose();
    super.dispose();
  }
}