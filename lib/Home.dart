import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//Biblioteca responsavel por recuperar o caminho dos arquivos, seja no ios
// ou no android
import 'package:path_provider/path_provider.dart';
import 'dart:io'; //Processamento de arquivos
import 'dart:async';
import 'dart:convert';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

//TODO ele não esta trazendo o arquivo novamente...


class _HomeState extends State<Home> {
  List listaTarefas = new List();
  //Salvar a tarefa removida para fazer a recuperação
  Map<String,dynamic> ultimaTarefaRemovida = Map();
  TextEditingController _controllerTarefa = TextEditingController();

  //Retonar o arquivo
  Future<File> _getFile() async{
    //Pegar o diretorio do arquivo que sera salvo
    final diretorio = await getApplicationDocumentsDirectory();
    return  File("${diretorio.path}/dados.json"); //caminho oonde está o arquivo
  }

  Widget criarItemLista(context,index){
    //final item = listaTarefas[index]["titulo"]; //O ideal é fazer chaves
    // mais completas para que não tenha a possibilidade de repetir
    return Dismissible(
      ///Gerar a chave de acordo a data em milisegundos faz com que essa
      ///chave nunca seja igual, mesmo quando se recupera um item
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction){
        //Pegar o ultimo item excluído, para que se possa desfazer a ação
        ultimaTarefaRemovida = listaTarefas[index];

        //Remover item da lista
        listaTarefas.removeAt(index);
        salvarArquivo();

        //snackBar
        final snackBar = SnackBar(
          //backgroundColor: Colors.green,
          duration: Duration(seconds: 5),
            content: Text("Tarefa removida"),
          //Ação dentro da snackBar
          action: SnackBarAction(
              label: "Desfazer",
              onPressed: (){
                setState(() {
                  //Recuperar a tarefa e colocar na mesma posição em que estava
                  listaTarefas.insert(index, ultimaTarefaRemovida);
                });
                salvarArquivo();
              }),
        );

        //apresentar a SnackBar
        Scaffold.of(context).showSnackBar(snackBar);
      },
      background: Container(
        color: Colors.red,
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Icon(
              Icons.delete,
              color: Colors.white,
            )
          ],
        ),
      ),

      child: CheckboxListTile(
        title: Text(listaTarefas[index]['titulo']),
        value: listaTarefas[index]['realizada'],
        onChanged: (valorAlterado){
          setState(() {
          listaTarefas[index]['realizada']=valorAlterado;
          });
        salvarArquivo();
      },
      )
    );
  }

  salvarTarefa(){

    String textoDigitado = _controllerTarefa.text;

    Map<String, dynamic> tarefa = Map();
    tarefa["titulo"]=textoDigitado;
    tarefa["realizada"] = false;

    setState(() {
      listaTarefas.add(tarefa);
    });
    salvarArquivo();
    _controllerTarefa.text="";
  }

  salvarArquivo() async {

    var arquivo = await _getFile();

    
    //converter para json
    String dados = json.encode(listaTarefas);
    //Escrever conteudo no arquivo
    arquivo.writeAsString(dados);

  }

  _lerArquivo() async{
    try{
      final arquivo = await _getFile();
      //Ler o arquivo
     return arquivo.readAsString();
    }catch(e){
      return null;
    }

  }

  @override
  void initState() {
    //Tentar ler o arquivo assim que o app se iniciar
    _lerArquivo().then((dados){ // "then" após ler faça isso...
      setState(() {
        listaTarefas = json.decode(dados);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    salvarArquivo();
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista Tarefas"),
        backgroundColor: Colors.purple,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
                itemCount: listaTarefas.length,
                itemBuilder: criarItemLista
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.purple,
        onPressed: (){
          showDialog(
              context: context,
              builder: (context){
                return AlertDialog(
                  title: Text("Adicionar tarefa"),
                  content: TextField(
                    controller: _controllerTarefa,
                    decoration: InputDecoration(
                      labelText: "Digite a sua tarefa"
                    ),
                    onChanged: (text){

                    },
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text("Cancelar"),
                      onPressed: () =>Navigator.pop(context),
                    ),
                    FlatButton(
                      child: Text("Salvar"),
                      onPressed: (){
                        salvarTarefa();
                        Navigator.pop(context);
                      },
                    )
                  ],
                );
              }
          );
         },
      ),
    );
  }
}
