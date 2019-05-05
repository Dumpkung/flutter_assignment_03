import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

class Todostate extends StatefulWidget {
  Todostate({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _TodoListScreenPage createState() => _TodoListScreenPage();
}

class _TodoListScreenPage extends State<Todostate> {
  //User Click Button in Task Page Change task to complete
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

  //showuncompletetask
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
        //First Check HaveData?
        if (!snapshot.hasData) return list;
        int check = 0;
        int lenghofvalue = snapshot.data.documents.length;
        //If Have Then Loop Check Again
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

  //User Click Button in Task Page Change complete to task
  Widget _donechangetoundo(BuildContext context, DocumentSnapshot document) {
    return (document['done'] == 1)
        ? ListTile(
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
          )
        : Column();
  }

  //showcompletetask
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
        //First Check HaveData?
        if (!snapshot.hasData) return list;
        int havedata = 0;
        int lenghofvalue = snapshot.data.documents.length;
        //If Have Then Loop Check Again
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
    //Add Task
    // unCompleteItems = List();
    // havecount = false;
    // _completeItems = List();
    // count = 0;
    // await Navigator.pushNamed(context, "/add");
    // _datamanage.getTodo().then((r) {

    //   //check it have space to add
    //   //***Not use Now***/
    //   for(var j = 0; j < counttodo; j++) {
    //     count += 1;
    //   }
    //   if(count > 0) {
    //     havecount = true;
    //   }

    //   //add list
    //   //Use//
    //   for (var i = 0; i < r.length; i++) {
    //     (r[i].done == false)?setState(() { _unCompleteItems.add(r[i]);}):setState(() { _completeItems.add(r[i]);});
    //   }
    // });
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => AddItempage()));
  }

  Future _delete() async {
    var length;
    // count = 0;
    // havedelete = false;
    // for(var j = 0; j < countcomplete; j++) {
    //     count += 1;
    //   }
    //   if(count > 0) {
    //     havedelete = true;
    //   }

    //   //delete item
    //   //Use//
    // _datamanage.deleteTodo();
    //       setState(() {
    //         _completeItems =List();
    //       });
    final QuerySnapshot result =
        await Firestore.instance.collection('todo').getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    length = documents.length;
    for (var i = 0; i < length; i++) {
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
