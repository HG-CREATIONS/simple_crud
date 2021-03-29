import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final db = Firestore.instance;
  String task;
  void showdialog(bool isUpdate, DocumentSnapshot ds) {
    GlobalKey<FormState> formkey = GlobalKey<FormState>();
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: isUpdate ? Text("Update PLayer") : Text("Add Player"),
            content: Form(
              key: formkey,
              autovalidateMode: AutovalidateMode.always,
              child: TextFormField(
                autofocus: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Player",
                ),
                validator: (_val) {
                  if (_val.isEmpty) {
                    return "Can't be empty!";
                  } else {
                    return null;
                  }
                },
                onChanged: (_val) {
                  task = _val;
                },
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  if (isUpdate) {
                    db
                        .collection('players')
                        .document(ds.documentID)
                        .updateData({'Player': task, 'time': DateTime.now()});
                  } else {
                    db
                        .collection('players')
                        .add({'Player': task, 'time': DateTime.now()}); //create

                  }
                  Navigator.pop(context);
                },
                child: Text("Add"),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () => showdialog(false, null),
            child: Icon(Icons.add),
          ),
          appBar: AppBar(
            title: Text("SquadList"),
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: db.collection('players').orderBy('time').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshot.data.documents[index];
                    return Container(
                        child: ListTile(
                      title: Text(ds['Player'] //retrieve
                          ),
                      onLongPress: () {
                        //delete
                        db
                            .collection('players')
                            .document(ds.documentID)
                            .delete();
                      },
                      onTap: () {
                        //update
                        showdialog(true, ds);
                      },
                    ));
                  },
                );
              } else if (snapshot.hasError) {
                return CircularProgressIndicator();
              } else {
                return CircularProgressIndicator();
              }
            },
          )),
    );
  }
}
