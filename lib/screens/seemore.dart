import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart' as fb;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:myufp/models/evento.dart';

class Seemore extends StatefulWidget {
  String number;
  Event eventoAtual;

  Seemore(this.eventoAtual,this.number);


  @override
  State<StatefulWidget> createState() => SeemoreState(this.eventoAtual,this.number);


}


class SeemoreState extends State<Seemore> {

  String number;
  Event eventoAtual;
  bool going = false;
  bool interested= false;
  bool refreshed = false;

  SeemoreState(this.eventoAtual,this.number);



  Future<bool> getGoin() async{
    var instantace = fb.FirebaseDatabase.instance.reference();
    fb.DataSnapshot pp = await instantace.child('eventos').child(eventoAtual.nome).child('likes').child(number).once();
      if(pp.value != null) return true;
      else return false;
  }

   Future<bool> getInterest() async{
    var instantace = fb.FirebaseDatabase.instance.reference();
    fb.DataSnapshot pp = await instantace.child('eventos').child(eventoAtual.nome).child('interesse').child(number).once();
      if(pp.value != null) return true;
      else return false;
  }

  @override
  Widget build(BuildContext context) {
    
    if(!refreshed) {
    var heyhey = getGoin();
        heyhey.then((valor) {
          // check se ja deu gosto ou nao
          var heyhey2 = getInterest();
          heyhey2.then((valor2) {
            // check se ja deu interessado ou nao
            setState(() {
            going = valor;
            interested = valor2;
            refreshed = true;
           });
          });
          
        });
    }
   
   
    return new Scaffold(
      appBar: new AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Map<String,bool>mapaDosBools = new Map<String,bool>();
            mapaDosBools['likes'] = going;
            mapaDosBools['interesse'] = interested;
            Navigator.pop(context,mapaDosBools);
          },
        ),
        title: Text(eventoAtual.nome),
        backgroundColor: Colors.white
      ),
      body: refreshed? ListView(
        children: <Widget>[
          CachedNetworkImage(
                      imageUrl: eventoAtual.photoUrl,
                      placeholder: (context, url) => new CircularProgressIndicator(),
                      errorWidget: (context, url, error) => new Icon(Icons.error),
                  ),
          SizedBox(height: 20,),
          Column(
            children: <Widget>[
                  Text("Author", style: TextStyle( fontWeight: FontWeight.bold),),
                  Text(eventoAtual.autor),
                  SizedBox(height: 10,),
                
                  Text("Date", style: TextStyle( fontWeight: FontWeight.bold),),
                  Text(eventoAtual.horas),
                  SizedBox(height: 20,),
               
                  Text("Description", style: TextStyle( fontWeight: FontWeight.bold),),
                  Text(eventoAtual.descricao ,textAlign: TextAlign.center,),
            ],
          ),
          
          SizedBox(height: 20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.check, color: going? Colors.green : Colors.grey,),
                              onPressed: () async{
                                //aumenta os likes
                                var instantace = fb.FirebaseDatabase.instance.reference();
                                var likezitos = instantace.child('eventos').child(eventoAtual.nome).child('likes');
                                likezitos.child('total').once().then((likkes) {
                                  int hey = int.parse(likkes.value.toString());
                                  print(hey);
                                  if(going) {
                                    likezitos.update({
                                      'total' : hey+1
                                    });
                                    likezitos.update({
                                      number: '${hey+1}',
                                    });
                                  } else {
                                    likezitos.update({
                                      'total' : hey-1
                                    });
                                    likezitos.update({
                                      number: null,
                                    });
                                }
                                });
                                setState(() {
                                  going = !going;
                                });
                            },
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Text("I'm going"),
                          ),
                          IconButton(
                            icon: Icon(Icons.tag_faces, color: interested? Colors.yellow[700] : Colors.grey,),
                            onPressed: () {
                              //aumenta os interessados
                                var instantace = fb.FirebaseDatabase.instance.reference();
                                var likezitos = instantace.child('eventos').child(eventoAtual.nome).child('interesse');
                                likezitos.child('total').once().then((likkes) {
                                  int hey = int.parse(likkes.value.toString());
                                  print(hey);
                                  if(interested) {
                                    likezitos.update({
                                      'total' : hey+1
                                    });
                                    likezitos.update({
                                      number: '${hey+1}',
                                    });
                                  } else {
                                    likezitos.update({
                                      'total' : hey-1
                                    });
                                    likezitos.update({
                                      number: null,
                                    });
                                }
                                });
                                setState(() {
                                  interested =  !interested;
                                });
                              
                            },
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Text("Interested"),
                          )
                        ],
                      ),
                      SizedBox(height: 20,),
        ],
      ): new Center(
         child: new CircularProgressIndicator(valueColor: AlwaysStoppedAnimation (Colors.green)), 
       ),
      
    );
  }



}