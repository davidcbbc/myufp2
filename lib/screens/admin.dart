import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_database/firebase_database.dart' as fb;
import 'package:myufp/models/evento.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:cached_network_image/cached_network_image.dart';


class Admin extends StatefulWidget {


  @override
  State<StatefulWidget> createState() =>AdminState();



}


class AdminState extends State<Admin> {
Widget actual;
bool refreshed = false;
bool connected = true;


Future<List<Event>> buscarEventos() async {
   print("A ir buscar eventos da bd");
    List<Event> eventosLista = new List<Event>();
    return fb.FirebaseDatabase.instance.reference().child('eventos').once().then((eventos){
      if(eventos.value == null) return null;
      fb.DataSnapshot ds = eventos;
     
      Map mapa = ds.value;
      if(mapa != null) {
        // Caso hajam realmente eventos
        
        mapa.forEach((nome , resto) {
          String nomezito = nome;
          Map restito = resto;
          String photo = restito['photoUrl'].toString();
          String descricao = restito['desc'].toString();
          String autor = restito['autor'].toString();
          String data = restito['data'].toString();
          Map likes = restito['likes'];
          Map interesses = restito['interesse'];
          int numeroInteresse = int.parse(interesses['total'].toString());
          int numeroLikes = int.parse(likes['total'].toString());
          Event novoEvento = new Event("EVENT", nomezito, photoUrl: photo, descricao: descricao , likes: numeroLikes, interesse: numeroInteresse , autor: autor,horas: data);
          //print(novoEvento.toString());
          eventosLista.add(novoEvento);
         
        });
        return eventosLista;
      } else return null;
    });

}
 void buscarCards() {
    // Esta funcao encarrega-se de ir buscar eventos a database e formata em cards
    List<Widget> listita = new List<Widget>();
   var eventos = buscarEventos();
    eventos.then((eventitos) {
      
      if(eventitos == null) {
        
        setState(() {
       actual = Center(
     
        child: Text("Whitout events , dear admin", style: TextStyle(fontSize: 20),),
     
        );
        refreshed = true;
     });
     return;
      }
     List<Event> aux = eventitos;

     for(int i = 0 ; i < aux.length ; i++) {
       // Cria uma card para cada envento que exista
        listita.add(Card(
        elevation: 15.0,
        margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
        child: Container(
          decoration: BoxDecoration(color: Colors.white),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 20.0,vertical: 10.0),
            title: Container(
              padding: EdgeInsets.only(right: 12.0),
              decoration: new BoxDecoration(
                border: new Border(
                  right: new BorderSide(width: 1.0, color: Colors.white24)
                )
              ),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                        Text(aux[i].autor, style: TextStyle(color: Colors.grey),),
                        Text(aux[i].nome , style: TextStyle(fontWeight: FontWeight.bold),),
                        Text(aux[i].horas, style: TextStyle(color: Colors.grey),),
                    ],
                  ),
                  
                  SizedBox(
                    height: 2,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        children: <Widget>[

                          IconButton(
                            icon: Icon(Icons.check, color:Colors.black,),
                            onPressed: () {

                            },
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Text(aux[i].likes.toString()),
                          ),
                          IconButton(
                            icon: Icon(Icons.tag_faces, color:Colors.black,),
                            onPressed: () {

                            },
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Text(aux[i].interesse.toString()),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete_forever),
                            onPressed: () {
                              // DELETE EVENT
                            _alertaDeleteEvent(context, aux[i].nome);
                            },
                          )
                        ],
                      ),
                     
                    ],
                  )
                
                ],

              )
            ),
            
          ),
        ),
      ));

     }
     setState(() {
       actual = Center(
      child: Column(
        children: listita,
      ),
    );
    refreshed = true;
     });
    
   });
   //return CircularProgressIndicator();
    
  }
  
Future<bool> isConnected() async{
  // dar check a conexao internet
  try{
    var result =  await InternetAddress.lookup('siws.ufp.pt');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      print("connectado!");
      return true;
    }
  }on SocketException {
    print("desconnectado!");
    return false;
  }
}


  @override
  Widget build(BuildContext context) {


  if (!refreshed){
    isConnected().then((isOn) {
      if(isOn) {
        //conectado
          buscarCards();  
      } else {
        // nao conectado
        setState(() {
        connected = false;
        refreshed = true;
      });
      }
    });
    
   } 


    return new Scaffold(
      appBar: AppBar(
        title: Text("Admin"),
        backgroundColor: Colors.red[100],
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // add event
              _criarEvento(context);
            },
          )
        ],
      ),
      body: connected ? actual == null? Text(""): actual : 
       new Center(
        child: new Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset('assets/no_wifi.png',scale: 2.8,color: Colors.grey[400],),
          Text("Please check your connection\n \t\t\t\t\t\t\t\t\t\t\tand refresh",style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold),),
        
        ],
      ),
      )
      
    );
  }

   _alertaDeleteEvent(context, String name) {
     // Alert para saber se realemente quer deleter o evento
    Alert(
      closeFunction: () {
        print("Quiting ...");
      },
      context: context,
      type: AlertType.warning,
      title: "Delete \"$name\" ?",
      desc: "Please remind that this action is irreversible",
      buttons: [
        DialogButton( 
          child: Text("Delete",
          style: TextStyle(color: Colors.white, fontSize: 20),),
          onPressed: () {
            // Delete the event
            fb.FirebaseDatabase.instance.reference().child('eventos').child(name).set(null);
            setState(() {
              refreshed = false;
            });
            return Navigator.pop(context);
            
          } ,
          width:120,
          color: Colors.red,
        ),
        DialogButton( 
          child: Text("Cancel",
          style: TextStyle(color: Colors.white, fontSize: 20),),
          onPressed: () {
            return Navigator.pop(context);
          } ,
          width:120,
          color: Colors.grey,
        ),
      ]
    ).show();
  }


      _criarEvento(context) {
    String nome;
    String descricao;
    String data;
    String autor;
    String photoUrl;
    final _formKey = GlobalKey<FormState>();
    Alert(
      closeFunction: () {
        print("Quiting ...");
      },
      context: context,
      title: "Create an event",
      content: Column(
        children: <Widget>[
          Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[  
          TextFormField(
            onSaved: (nomezito) {
              nome = nomezito;
            },
            maxLength: 15,
            cursorColor: Colors.black,
            autofocus: false,
            initialValue: '',
                  validator: (val) {
            if(val.isEmpty) return "Please enter the name";
              },
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.green),
                borderRadius: BorderRadius.all(Radius.circular(12.0))
              ),
               enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
              ),
              icon: Icon(Icons.title,color: Colors.grey,),
              hintText: "Name",
              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
            ),
            
          ),
          TextFormField(
            onSaved: (desc) {
              descricao = desc;
            },
            validator: (value) {
              if(value.isEmpty) return "Please enter at least a short description";
            },
            keyboardType: TextInputType.multiline,
            maxLines: null,
            maxLength: 300,
            cursorColor: Colors.black,
            autofocus: false,
            initialValue: '',
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.green),
                borderRadius: BorderRadius.all(Radius.circular(12.0))
              ),
               enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
              ),
              icon: Icon(Icons.description,color: Colors.grey,),
              hintText: "Description",
              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
            ),
            
          ),
          
          TextFormField(
            onSaved: (value) {
               data = value;

            },
            cursorColor: Colors.black,
            keyboardType: TextInputType.number,
            autofocus: false,
            validator: (val) {
              if(val.isEmpty) return "Please insert date";
              if(val.isNotEmpty) {
              if(val.length != 10) return "Please insert a valid date format";
              }
            },
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.green),
                borderRadius: BorderRadius.all(Radius.circular(12.0))
              ),
               enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
              ),
              icon: Icon(Icons.watch,color: Colors.grey,),
              hintText: "Date (dd/mm/yyyy)",
              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
            ),  
          ),
          SizedBox(height: 10),
           TextFormField(
            onSaved: (desc) {
              photoUrl = desc;
            },
            validator: (value) {
              if(value.isEmpty) return "Please enter a link to a image";
            },
            keyboardType: TextInputType.multiline,
            maxLines: null,
            cursorColor: Colors.black,
            autofocus: false,
            initialValue: '',
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.green),
                borderRadius: BorderRadius.all(Radius.circular(12.0))
              ),
               enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
              ),
              icon: Icon(Icons.link,color: Colors.grey,),
              hintText: "Image link",
              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
            ),
            
          ),
          TextFormField(
            onSaved: (desc) {
              autor = desc;
            },
            validator: (value) {
              if(value.isEmpty) return "Please enter an author";
            },
            keyboardType: TextInputType.multiline,
            maxLines: null,
            cursorColor: Colors.black,
            autofocus: false,
            initialValue: '',
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.green),
                borderRadius: BorderRadius.all(Radius.circular(12.0))
              ),
               enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
              ),
              icon: Icon(Icons.account_circle, color: Colors.grey,),
              hintText: "Author",
              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
            ),
            
          ),
          
          ]),
      ),
        ],
      ),
      buttons: [
        DialogButton( 
          height: 35,
          child: Text("Ok",
          style: TextStyle(color: Colors.white, fontSize: 20),),
          onPressed: () async {
            // aqui cria o evento
            if(_formKey.currentState.validate()) {
              _formKey.currentState.save();
               Navigator.pop(context);
            print("nome $nome \n descricao $descricao \n data $data \n autor $autor \n photourl $photoUrl");
            _showEvent(nome,descricao,data,autor,photoUrl);
            }
           
            
          } ,
          width:120,
          color: Colors.green,
        ),
          DialogButton( 
          height: 35,
          child: Text("Cancel",
          style: TextStyle(color: Colors.white, fontSize: 20),),
          onPressed: () {
            return Navigator.pop(context);
          } ,
          width:120,
          color: Colors.grey,
        ),
      ]
    ).show();
  }

      
       _showEvent(String nome, String descricao , String data , String autor, String photoUrl) {
    
    Alert(
      closeFunction: () {
        print("Quiting ...");
      },
      context: context,
      title: "Create an event",
      content: Column(
        children: <Widget>[
          Card(
        elevation: 15.0,
        margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
        child: Container(
          width: 1700,
          decoration: BoxDecoration(color: Colors.white),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 20.0,vertical: 10.0),
            title: Container(
              padding: EdgeInsets.only(right: 12.0),
              decoration: new BoxDecoration(
                border: new Border(
                  right: new BorderSide(width: 1.0, color: Colors.white24)
                )
              ),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                        //Text(autor, style: TextStyle(color: Colors.grey),),
                        Text(nome , style: TextStyle(fontWeight: FontWeight.bold),),
                        //Text(data, style: TextStyle(color: Colors.grey),),
                    ],
                  ),
                  
                  SizedBox(height: 15),
                  CachedNetworkImage(
                      imageUrl: photoUrl,
                      placeholder: (context, url) => new CircularProgressIndicator(),
                      errorWidget: (context, url, error) => new Icon(Icons.error),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.check, color: Colors.grey,),
                            onPressed: () {

                            },
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Text("0"),
                          ),
                          IconButton(
                            icon: Icon(Icons.tag_faces, color:Colors.grey,),
                            onPressed: () {

                            },
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Text("0"),
                          )
                        ],
                      ),
                  
                    ],
                  )
                
                ],

              )
            ),
            
          ),
        ),
      )
        ],
      ),
      buttons: [
        DialogButton( 
          height: 35,
          child: Text("Create",
          style: TextStyle(color: Colors.white, fontSize: 20),),
          onPressed: () async {
            // aqui cria o evento na base de dados
            Map likitos = new Map();
            Map interesitos = new Map();
            interesitos['total'] = 0;
            likitos['total'] = 0;
            print("a criar");
            fb.FirebaseDatabase.instance.reference().child('eventos').child(nome).set({
              'autor' : autor,
              'data' : data,
              'desc' : descricao,
              'photoUrl' : photoUrl,
              'likes' : likitos,
              'interesse' : interesitos
            });
            setState(() {
              refreshed = false;
            });
            Navigator.pop(context);
          } ,
          width:120,
          color: Colors.green,
        ),
          DialogButton( 
          height: 35,
          child: Text("Cancel",
          style: TextStyle(color: Colors.white, fontSize: 20),),
          onPressed: () {
            return Navigator.pop(context);
          } ,
          width:120,
          color: Colors.grey,
        ),
      ]
    ).show();
  }



}