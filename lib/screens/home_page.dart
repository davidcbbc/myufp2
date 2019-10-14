import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:myufp/models/evento.dart';
import 'package:myufp/models/licenciaturas.dart';
import 'package:myufp/models/user.dart';
import 'package:myufp/screens/admin.dart';
import 'package:myufp/screens/assiduity.dart';
import 'package:myufp/screens/grades.dart';
import 'package:myufp/screens/login_page.dart';
import 'package:myufp/screens/menu.dart';
import 'package:myufp/screens/schedule.dart';
import 'package:firebase_database/firebase_database.dart' as fb;
import 'package:myufp/screens/secretary.dart';
import 'package:myufp/screens/seemore.dart';
import 'package:myufp/screens/teste.dart';
import 'package:myufp/screens/thecalendar.dart';
import 'package:myufp/services/myfiles.dart';

import '../services/myfiles.dart';
import '../services/myfiles.dart';
import '../services/myfiles.dart';
import '../services/myfiles.dart';
import './atm.dart';

class HomePage extends StatefulWidget {
  
  User _logged;     //user with valid token
  HomePage(this._logged);

  @override
  _HomePageState createState() => new _HomePageState(_logged);
}

class _HomePageState extends State<HomePage> {
  User _logged;
  bool liked = false;
  bool connected = true;
  bool interested = false;
  int likes = 143;
  bool refreshed = false;
  _HomePageState(this._logged);
  Widget actual;
  Map lastRefreshed = new Map();
  String imagem_licenciatura;
  bool isAdmin = false;
  bool licenca;
  bool semEventos = false;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

      if(isAdmin == null) {
      print("ISADMIN DEU ERRO (NULL)");
      isAdmin = false;
    } 
    licenca = true;
   Licenciaturas lp = new Licenciaturas();
   if(_logged.licenciatura == "hey" || _logged.licenciatura == "UFP") licenca = false;
   imagem_licenciatura = lp.lic[_logged.licenciatura];
    getAdmin().then((valor) {
      isAdmin = valor;
      setState(() {
        
      });
    });
  }




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
          bool like;
          bool inte;
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
          if(likes.containsKey(_logged.username)) like =true;
          else like = false;
          if(interesses.containsKey(_logged.username)) inte =true;
          else inte = false;


          Event novoEvento = new Event("EVENT", nomezito, photoUrl: photo, descricao: descricao , likes: numeroLikes, interesse: numeroInteresse , doIliked: like, doIinteress: inte, autor: autor,horas: data);
          //print(novoEvento.toString());
          eventosLista.add(novoEvento);


          // Event novoEvento = new Event("EVENT", nomezito, photoUrl: photo, descricao: descricao , likes: numeroLikes, interesse: numeroInteresse );
          // //print(novoEvento.toString());
          // eventosLista.add(novoEvento);
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
        //nao ha eventos
        print("SEM EVENTOS OH MANO");
        setState(() {
          semEventos = true;
          actual = Center(
            child: Text('No events at the moment' , style: TextStyle(fontSize: 20),),
          );
      refreshed = true;
      });
      return;
        }
     List<Event> aux = eventitos;

     for(int i = 0 ; i < aux.length ; i++) {
       // Cria uma card para cada envento que exista
       
       //print("----> ${aux[i].nome} : liked ${aux[i].doIliked} interested ${aux[i].doIinteress}");
        listita.add(Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        elevation: 15.0,
        margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30.0)),
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
                //crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                        Text(aux[i].autor, style: TextStyle(color: Colors.grey),),
                        Text(aux[i].nome , style: TextStyle(fontWeight: FontWeight.bold),),
                        Text(aux[i].horas, style: TextStyle(color: Colors.grey),),
                    ],
                  ),
                  
                  SizedBox(height: 15),
                  CachedNetworkImage(
                    height: 250,
                    width: 500,
                    imageUrl: aux[i].photoUrl,
                    placeholder: (context, url) => new CircularProgressIndicator(valueColor: AlwaysStoppedAnimation (Colors.green)),
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
                            icon: Icon(Icons.check, color: aux[i].doIliked?Colors.green : Colors.grey,),
                            onPressed: () {

                            },
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Text(aux[i].likes.toString()),
                          ),
                          IconButton(
                            icon: Icon(Icons.tag_faces, color: aux[i].doIinteress? Colors.yellow[900]:Colors.grey,),
                            onPressed: () {

                            },
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Text(aux[i].interesse.toString()),
                          )
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10.0)),
                        
                        height: 30,
                        width: 100,

                        child: FlatButton(
                          child: Text("See more"), 
                          onPressed: (){
                            // Caso carregue no bota para ver mais
                            Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => new Seemore(aux[i],_logged.username))).then((valor) {
                            // saber qual evento foi refrescado para mudar as cores dos icons
                            
                            lastRefreshed['nome'] = aux[i].nome;
                            
                            lastRefreshed['liked'] = valor['likes'];
                            lastRefreshed['interested'] = valor['interesse'];

                            // aux[i].doIliked = valor['likes'];
                            // aux[i].doIinteress  = valor['interesse'];
                            setState(() {
                              refreshed = false;
                              connected = true;
                            });
                            });
                          
                          },

                        ),
                      )
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
    connected = true;
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

    

 
  return new WillPopScope(    //WillPopScore evita andar para tras em androids e nao volta a pagina de login
      onWillPop: () async => false,
      child: new Scaffold(
      appBar: new AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                refreshed = false;
                connected = true;
              });
            },
          )
        ],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              //padding: const EdgeInsets.only(left: 20),
              child: Image.asset('assets/logotipinho.png',scale: 15,fit: BoxFit.contain, height: 32)
            ),
            Container(
              padding: const EdgeInsets.only(left: 8,right: 4), 
              child: Text("|", style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),)
            ),Container(
              //padding: const EdgeInsets.all(1.0), 
              child: Text("MYUFP", style: TextStyle(fontWeight: FontWeight.normal,color: Colors.grey),)
            ),
            Container(
              //padding: const EdgeInsets.all(1.0), 
              child: Text("v1.0.3", style: TextStyle(fontWeight: FontWeight.normal,color: Colors.grey,fontSize: 12),)
            ),
          ],
        ),
       
        backgroundColor: Colors.white,),
      drawer: new Drawer(
        child: new ListView(
          children: <Widget>[
            new UserAccountsDrawerHeader(
              accountName: new Text("${_logged.licenciatura}"),
              accountEmail: new Text(_logged.username,style: TextStyle(fontWeight: FontWeight.bold) ,),
              currentAccountPicture: new GestureDetector(
                child: new CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: licenca? Image.asset(imagem_licenciatura): null,
                ),
                onTap: () => print("This is your current account."),
              ),
              decoration: new BoxDecoration(
                color: Colors.transparent,
                // image: DecorationImage(
                //   //image: AssetImage('assets/tumb.png'),
                //      fit: BoxFit.cover)
              ),
            ),
            new ListTile(
              title: new Text("ATM Payment"),
              leading: new Icon(Icons.account_balance_wallet),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => new Atm(_logged.token)));
              }
            ),
            new ListTile(
              title: new Text("Assiduity"),
              leading: new Icon(Icons.assessment),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => new Assiduity(_logged.token)));
              }
            ),
            new ListTile(
              title: new Text("Grades"),
              leading: new Icon(Icons.assignment),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => new Grades(_logged.token)));
              }
            ),
            new ListTile(
              title: new Text("Calendar"),
              leading: new Icon(Icons.calendar_today),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => new TheCalendar(_logged.token,number: _logged.username,)));
              }
            ),
            new ListTile(
              title: new Text("Secretary Queue"),
              leading: new Icon(Icons.group),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => new Secretary()));
              }
            ),
            new ListTile(
              title: new Text("Bar Menu"),
              leading: new Icon(Icons.menu),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => new Menu.init()));
              }
            ),           
            new Divider(),
            new ListTile(
              title: new Text("Logout"),
              leading: new Icon(Icons.cancel),
              onTap: () {
                print("VOU SAIR");
                writeLoggedTxt(false);
                Navigator.of(context).pop();
                Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => new LoginPage()));
              },
            ),
            isAdmin? new ListTile(
              title: new Text("Admin"),
              leading: new Icon(Icons.gavel),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => new Admin()));
              },
            ): Text("")
          ],
        ),
      ),
      body: connected? (refreshed? semEventos ? actual :ListView(
          children: <Widget>[
            actual != null? actual : Text("")
            ],
          ) : Center(
            child: new CircularProgressIndicator(valueColor: AlwaysStoppedAnimation (Colors.green)),
          )) : 
          
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
      
      ),
    );
    
  }
}