import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main(){
  runApp(MaterialApp(
    home:Home(
      
    ),

  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _toDoControler = TextEditingController();
  List _toDoList = [];

  Map<String, dynamic> _lastRemove;
  int _lastRemovePos;


  @override
  void initState() {
    super.initState();
    _carregarDados().then((value){
      setState(() {
        _toDoList = json.decode(value);
      });
    });
  }

  void _adicionarTarefa() {
    setState(() {
      Map<String, dynamic> novaTarefa = Map();
      novaTarefa["Titulo"] = _toDoControler.text;
      _toDoControler.text = "";
      novaTarefa["Ok"] = false;
      _toDoList.add(novaTarefa);
      _salvarDados();
    });
  }

  Future<Null> _refresh() async{
    await Future.delayed(Duration(seconds:1));
    setState(() {
      _toDoList.sort((a, b){
        if(a["Ok"] && !b["Ok"]) return 1;
        else if(!a["Ok"] && b["Ok"]) return -1;
        else return 0;
      });
    });
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Tarefas"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _toDoControler,
                    decoration: InputDecoration(
                        labelText: "Nova Tarefa",
                        labelStyle: TextStyle(color: Colors.blueAccent)
                    ),
                  ),
            ),
                RaisedButton(
                  color: Colors.blueAccent,
                  child: Text("ADD"),
                  textColor: Colors.white,
                  onPressed: _adicionarTarefa,
                )
              ],
            ),
          ),
          Expanded(
              child: RefreshIndicator(onRefresh: _refresh,
                child: ListView.builder(
                    padding: EdgeInsets.only(top: 10.0),
                    itemCount: _toDoList.length,
                    itemBuilder: buildItem),
              )
          )
        ],

      ),
    );
  }

  Widget buildItem(context, index){
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(Icons.delete, color: Colors.white,),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text(_toDoList[index]["Titulo"]),
        value: _toDoList[index]["Ok"],
        secondary: CircleAvatar(
          child: Icon(_toDoList[index]["Ok"] ?
          Icons.check : Icons.error),
        ),
        onChanged: (check){
          setState(() {
            _toDoList[index]["Ok"] = check;
            _salvarDados();
          });
        },
      ),
      onDismissed: (direction){
        setState(() {
          _lastRemove = Map.from(_toDoList[index]);
          _lastRemovePos = index;
          _toDoList.removeAt(index);
          _salvarDados();

          final snack = SnackBar(
            content: Text("Tarefa \"${_lastRemove["Titulo"]}\" removida!"),
            action: SnackBarAction(label: "Desfazer",
              onPressed: (){
              setState(() {
                _toDoList.insert(_lastRemovePos, _lastRemove);
                _salvarDados();
              });
              },
            ),
            duration: Duration(seconds: 2),
          );
          Scaffold.of(context).removeCurrentSnackBar();
          Scaffold.of(context).showSnackBar(snack);
        });
      },
    );
  }

  Future<File> _buscarAquivo() async{
    final diretorio = await getApplicationDocumentsDirectory();
    return File("${diretorio.path}/data.json");
  }

  Future<File> _salvarDados() async{
    String data = json.encode(_toDoList);
    final arquivo = await _buscarAquivo();
    return arquivo.writeAsString(data);
  }

  Future<String> _carregarDados() async{
    try {
      final arquivo = await _buscarAquivo();
      return arquivo.readAsString();

    } catch(e) {
      return null;
    }
  }
}



