import 'package:flutter/material.dart';
import 'package:reifendb/dbmanager.dart';
import 'package:flutter_full_pdf_viewer/flutter_full_pdf_viewer.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as p;
import 'report.dart';

void main() => runApp(MyApp());

class PdfViewerPage extends StatelessWidget {
  String path;
  PdfViewerPage({Key key, this.path}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PDFViewerScaffold(path: path);
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DbManager dbmanager = new DbManager();

  final _zeichenController = TextEditingController();
  final _vlController = TextEditingController();
  final _vrController = TextEditingController();
  final _hlController = TextEditingController();
  final _hrController = TextEditingController();

  final _formKey = new GlobalKey<FormState>();
  Reifen reifen;
  List<Reifen> reifenList;
  int updateIndex;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          title: Text('Reifenprofil'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.picture_as_pdf),
              onPressed: () {
                reportView(context);
              },
            ),
            SizedBox(
              width: 10,
            ),
          ],
        ),
        body: ListView(
          children: <Widget>[
            Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        decoration:
                            new InputDecoration(labelText: 'Kennzeichen'),
                        controller: _zeichenController,
                        validator: (val) => val.isNotEmpty
                            ? null
                            : 'Bitte Kennzeichen eingeben.',
                      ),
                      TextFormField(
                        decoration:
                            new InputDecoration(labelText: 'Vorne Links'),
                        controller: _vlController,
                        validator: (val) =>
                            val.isNotEmpty ? null : 'Bitte Zahl eingeben.',
                      ),
                      TextFormField(
                        decoration:
                            new InputDecoration(labelText: 'Vorne Rechts'),
                        controller: _vrController,
                        validator: (val) =>
                            val.isNotEmpty ? null : 'Bitte Zahl eingeben.',
                      ),
                      TextFormField(
                        decoration:
                            new InputDecoration(labelText: 'Hinten Links'),
                        controller: _hlController,
                        validator: (val) =>
                            val.isNotEmpty ? null : 'Bitte Zahl eingeben.',
                      ),
                      TextFormField(
                        decoration:
                            new InputDecoration(labelText: 'Hinten Rechts'),
                        controller: _hrController,
                        validator: (val) =>
                            val.isNotEmpty ? null : 'Bitte Zahl eingeben.',
                      ),
                      RaisedButton(
                        textColor: Colors.white,
                        color: Colors.blueAccent,
                        child: Container(
                            width: width,
                            child: Text(
                              "Hinzufügen",
                              textAlign: TextAlign.center,
                            )),
                        onPressed: () {
                          _submitReifen(context);
                        },
                      ),
                      FutureBuilder(
                        future: dbmanager.getReifenList(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            reifenList = snapshot.data;
                            return ListView.builder(
                              shrinkWrap: true,
                              itemCount:
                                  reifenList == null ? 0 : reifenList.length,
                              itemBuilder: (BuildContext context, index) {
                                Reifen rf = reifenList[index];
                                return Card(
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                        width: width * 0.7,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              'Kennzeichen: ${rf.zeichen}',
                                              style: TextStyle(fontSize: 15),
                                            ),
                                            Text(
                                              'Vorne Links: ${rf.vl}',
                                              style: TextStyle(fontSize: 15),
                                            ),
                                            Text(
                                              'Vorne Rechts: ${rf.vr}',
                                              style: TextStyle(fontSize: 15),
                                            ),
                                            Text(
                                              'Hinten Links: ${rf.hl}',
                                              style: TextStyle(fontSize: 15),
                                            ),
                                            Text(
                                              'Hinten Rechts: ${rf.hr}',
                                              style: TextStyle(fontSize: 15),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          _zeichenController.text = rf.zeichen;
                                          _vlController.text = rf.vl;
                                          _vrController.text = rf.vr;
                                          _hlController.text = rf.hl;
                                          _hrController.text = rf.hr;
                                          reifen = rf;
                                          updateIndex = index;
                                        },
                                        icon: Icon(Icons.edit,
                                            color: Colors.blue),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          dbmanager.deleteReifen(rf.id);
                                          setState(() {
                                            reifenList.removeAt(index);
                                          });
                                        },
                                        icon: Icon(Icons.delete,
                                            color: Colors.red),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          }
                          return new CircularProgressIndicator();
                        },
                      ),
                    ],
                  ),
                )),
          ],
        ));
  }

  void _submitReifen(BuildContext context) {
    if (_formKey.currentState.validate()) {
      if (reifen == null) {
        Reifen rf = new Reifen(
            zeichen: _zeichenController.text,
            vl: _vlController.text,
            vr: _vrController.text,
            hl: _hlController.text,
            hr: _hrController.text);
        dbmanager.insertReifen(rf).then((id) => {
              _zeichenController.clear(),
              _vlController.clear(),
              _vrController.clear(),
              _hlController.clear(),
              _hrController.clear(),
              print('Reifen wurde in die Datenbank Nummer ${id} hinzugefügt')
            });
      } else {
        reifen.zeichen = _zeichenController.text;
        reifen.vl = _vlController.text;
        reifen.vr = _vrController.text;
        reifen.hl = _hlController.text;
        reifen.hr = _hrController.text;

        dbmanager.updateReifen(reifen).then((id) => {
              setState(() {
                reifenList[updateIndex].zeichen = _zeichenController.text;
                reifenList[updateIndex].vl = _vlController.text;
                reifenList[updateIndex].vr = _vrController.text;
                reifenList[updateIndex].hl = _hlController.text;
                reifenList[updateIndex].hr = _hrController.text;
              }),
              _zeichenController.clear(),
              _vlController.clear(),
              _vrController.clear(),
              _hlController.clear(),
              _hrController.clear(),
              reifen = null
            });
      }
    }
  }
}
