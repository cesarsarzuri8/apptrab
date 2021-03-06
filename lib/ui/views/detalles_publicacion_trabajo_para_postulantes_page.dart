import 'dart:ui';

import 'package:app/core/models/calificacionDeEmpleadoAEmpleador.dart';
import 'package:app/core/models/chatModel.dart';
import 'package:app/core/models/publicacionTrabajoAlgoliaModel.dart';
import 'package:app/core/models/userModel.dart';
import 'package:app/core/viewmodels/crudModel.dart';
import 'package:app/core/viewmodels/login_state.dart';
import 'package:app/ui/views/agregar_propuesta_postulante_trabajo_page.dart';
import 'package:app/ui/views/chat_page.dart';
import 'package:app/ui/views/personal_information_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DetallesPublicacionTrabajoParaPostulantesPage extends StatefulWidget {
  final PublicacionTrabajoAlgolia publicacionTrabajoAlgolia;
  DetallesPublicacionTrabajoParaPostulantesPage({Key key,this.publicacionTrabajoAlgolia}) : super(key: key);

  @override
  _DetallesPublicacionTrabajoParaPostulantesPageState createState() {
    return _DetallesPublicacionTrabajoParaPostulantesPageState();
  }
}

class _DetallesPublicacionTrabajoParaPostulantesPageState extends State<DetallesPublicacionTrabajoParaPostulantesPage> {
  GlobalKey<ScaffoldState> _scaffoldKey=new GlobalKey();
  var _formatPublicacion = DateFormat.yMMMd('es').add_jm();
  bool _cargandoChat=false;
  String sp='';
  List<CalificacionDeEmpleadoAEmpleador> calificacionesAEmpleador;

  @override
  void initState() {
    super.initState();

  }


  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _crud= Provider.of<crudModel>(context);
    final User infoUser=Provider.of<LoginState>(context).infoUser();
    // TODO: implement build
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(63, 81, 181, 1.0),
        title: Text(widget.publicacionTrabajoAlgolia.titulo),
      ),

      floatingActionButton:infoUser.id==widget.publicacionTrabajoAlgolia.idUserPublicador?null:
      FloatingActionButton.extended(
        onPressed: (){
          if(infoUser!=null){
            if(infoUser.id==widget.publicacionTrabajoAlgolia.idUserPublicador){
              _scaffoldKey.currentState.showSnackBar(
                  SnackBar(
                    duration: Duration(milliseconds: 2000),
                    elevation: 6.0,
                    behavior: SnackBarBehavior.floating,
                    content: Row(
                      children: <Widget>[
                        Icon(Icons.error),
                        SizedBox(width: 20.0,),
                        Expanded(child: Text("Usted publico este trabajo."),)
                      ],
                    ),
                  )
              );
            }
            else{
              if(infoUser.token==""){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>PersonalInformationPage(user: infoUser,)));
              }else{
                Navigator.push(context, MaterialPageRoute(builder: (context)=>AgregarPropuestaPostulanteTrabajoPage(publicacionTrabajoAlgolia: widget.publicacionTrabajoAlgolia,)));
              }

            }
          }
        },
        label: Text("Enviar propuesta"),
        icon: Icon(Icons.send),
        backgroundColor: Color.fromRGBO(255, 193, 7, 1),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Container(
        color: Color.fromRGBO(189, 189, 189, 0.01),
        child: FutureBuilder(
          future: _crud.getUserById(widget.publicacionTrabajoAlgolia.idUserPublicador),
          builder: (_, userSnap){
            if(userSnap.connectionState==ConnectionState.waiting){
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            else{
              if(userSnap.data==null){
                return
                  Center(
                    child: ListView(
                      children: <Widget>[
                        SizedBox(height: 40,),
                        Icon(Icons.error,size: 120.0,color: Color.fromRGBO(197, 202, 232, 1.0),),
                        SizedBox(height: 10,),
                        Center(
                          child: Text("La publicación no existe.",style: TextStyle(color: Colors.black38),),
                        ),
                      ],
                    ),
                  );
              }
              else{
                User userPublicador=userSnap.data;
                return
                    ListView(
                      padding: EdgeInsets.only(top: 8.0,right: 8.0,left: 8.0, bottom: 30.0),
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Icon(Icons.description,color: Colors.blue),
                            Text(" "+widget.publicacionTrabajoAlgolia.estadoPublicacionTrabajo,style: TextStyle(color: Colors.blueGrey),)
                          ],
                        ),
                        Divider(),
                        Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0,right: 10.0, left: 10.0),
                                child: Text("PUBLICADO POR",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.indigo),),
                              ),
                              ListTile(
                                leading: CircleAvatar(
                                  radius: 30.0,
                                  child: ClipOval( child: Image.network(userPublicador.urlImagePerfil,width: 60,height: 60,fit: BoxFit.cover,),
                                  ),
                                ),
                                title: Text(' '+userPublicador.nombreCompleto,style: TextStyle(fontSize: 16,color: Color.fromRGBO(33, 33, 33, 1)),),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Icon(Icons.location_on,color: Colors.black38,),
                                        Text(userPublicador.ciudadRecidencia),
                                      ],
                                    ),
                                    FutureBuilder(
                                        future: _crud.getCalificacionesAEmpleador(userPublicador.id),
                                        builder: (context, calificacionesAEmpleadorSnap){
                                          if(calificacionesAEmpleadorSnap.connectionState==ConnectionState.waiting){
                                            return Center(
                                              child: Text("Cargando..."),
                                            );
                                          }
                                          else{
                                            calificacionesAEmpleador=calificacionesAEmpleadorSnap.data;
                                            num numeroDeCalificaciones=0;
                                            num sumaCalificaciones=0;
                                            calificacionesAEmpleador.asMap().forEach(( i, calificacion){
                                              if(calificacion.calificacionDeEmpleado !=0 ){
                                                numeroDeCalificaciones++;
                                                sumaCalificaciones=sumaCalificaciones+calificacion.calificacionDeEmpleado;
                                              }
                                            });
                                            return numeroDeCalificaciones==0?Text("Calificación de empleador: Sin calificaciones") :Text("  Calificación de empleador: "+(sumaCalificaciones/numeroDeCalificaciones).toString()+"/10");
                                          }
                                        }
                                    ),
                                  ],
                                ),
                                trailing: infoUser.id==userPublicador.id? null:
                                IconButton(
                                  icon: Icon(Icons.message,size: 30,color: Colors.green,),
                                  onPressed: ()async{
                                    if(_cargandoChat==true){
                                      print("esta cargando");
                                    }else{
                                      _cargandoChat=true;
                                      print(infoUser.id);
                                      print(userPublicador.id);
                                      Chat chat=await _crud.getChat(infoUser.id, userPublicador.id);
                                      _cargandoChat=false;
                                      if(chat==null){
                                        print("no existe un chat algo esta mal se supone que se tenia que registrar");
                                      }else{
                                        print("chat: "+chat.toString());
                                        _cargandoChat? null
                                            :infoUser.token==""?
                                        Navigator.push(context, MaterialPageRoute(builder: (context)=>PersonalInformationPage(user: infoUser,))):
                                        Navigator.push(context, MaterialPageRoute(builder: (context)=>ChatPage(otroUser: userPublicador,chat: chat,)));
                                      }
                                    }
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
//                        Card(
//                          child: Column(
//                            children: <Widget>[
//                              Padding(
//                                padding: const EdgeInsets.only(top: 10.0,right: 10.0, left: 10.0),
//                                child: Text("PUBLICADO POR",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.indigo),),
//                              ),
//                              Row(
//                                children: <Widget>[
//                                  Container(
//                                    child: CircleAvatar(
//                                      radius: 30.0,
//                                      child: ClipOval( child: Image.network(userPublicador.urlImagePerfil,width: 60,height: 60,fit: BoxFit.cover,),
//                                      ),
//                                    ),
//                                    padding: EdgeInsets.all(10.0),
//                                  ),
//                                  Column(
//                                    children: <Widget>[
//                                      Text(' '+userPublicador.nombreCompleto,style: TextStyle(fontSize: 16,color: Color.fromRGBO(33, 33, 33, 1)),),
//                                      Row(
//                                        children: <Widget>[
//                                          Icon(Icons.location_on,color: Colors.black38,),
//                                          Text(userPublicador.ciudadRecidencia)
//                                        ],
//                                      ),
//                                      FutureBuilder(
//                                          future: _crud.getCalificacionesAEmpleador(userPublicador.id),
//                                          builder: (context, calificacionesAEmpleadorSnap){
//                                            if(calificacionesAEmpleadorSnap.connectionState==ConnectionState.waiting){
//                                              return Center(
//                                                child: Text("Cargando..."),
//                                              );
//                                            }
//                                            else{
//                                              calificacionesAEmpleador=calificacionesAEmpleadorSnap.data;
//                                              num numeroDeCalificaciones=0;
//                                              num sumaCalificaciones=0;
//                                              calificacionesAEmpleador.asMap().forEach(( i, calificacion){
//                                                if(calificacion.calificacionDeEmpleado !=0 ){
//                                                  numeroDeCalificaciones++;
//                                                  sumaCalificaciones=sumaCalificaciones+calificacion.calificacionDeEmpleado;
//                                                }
//                                              });
//                                              return numeroDeCalificaciones==0?Text(" Calificación de empleador: Sin calificaciones") :Text("  Calificación de empleador: "+(sumaCalificaciones/numeroDeCalificaciones).toString()+"/10");
//                                            }
//                                          }
//                                      ),
//                                    ],
//                                    crossAxisAlignment: CrossAxisAlignment.start,
//                                  ),
//                                  Expanded(
//                                      child: infoUser.id==userPublicador.id?
//                                      Container():
//                                  Container(
//                                    child: Container(
//                                      child: IconButton(
//                                          icon: Icon(Icons.message,size: 30,color: Colors.green,),
//                                          onPressed: ()async{
//                                            if(_cargandoChat==true){
//                                              print("esta cargando");
//                                            }else{
//                                              _cargandoChat=true;
//                                              print(infoUser.id);
//                                              print(userPublicador.id);
//                                              Chat chat=await _crud.getChat(infoUser.id, userPublicador.id);
//                                              _cargandoChat=false;
//                                              if(chat==null){
//                                                print("no existe un chat algo esta mal se supone que se tenia que registrar");
//                                              }else{
//                                                print("chat: "+chat.toString());
//                                                _cargandoChat? null
//                                                    :infoUser.token==""?
//                                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>PersonalInformationPage(user: infoUser,))):
//                                                Navigator.push(context, MaterialPageRoute(builder: (context)=>ChatPage(otroUser: userPublicador,chat: chat,)));
//                                              }
//                                            }
//                                          },
//                                          ),
//                                      padding: EdgeInsets.symmetric(horizontal: 8.0),
//                                      alignment: Alignment.centerRight,
//                                    ),
//                                  )
//                                  )
//
//                                ],
//                              ),
//                            ],
//                            crossAxisAlignment: CrossAxisAlignment.start,
//                          ),
//                        ),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: <Widget>[
                                Text("DETALLES",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.indigo),),
                                Center(
                                  child: Text(widget.publicacionTrabajoAlgolia.nombreSubcategoria,style: TextStyle(fontSize: 16,color: Colors.blueGrey,fontWeight: FontWeight.bold),),
                                ),
                                SizedBox(height: 5.0,),
                                Text("Lugar de Trabajo: "+ widget.publicacionTrabajoAlgolia.modalidadDeTrabajo),
                                SizedBox(height: 5.0,),
                                Text("Presupuesto: "+widget.publicacionTrabajoAlgolia.presupuesto.toString()+" Bs."),
                                SizedBox(height: 5.0,),
                                Text("Razón de pago: "+widget.publicacionTrabajoAlgolia.razonDePago),
                                SizedBox(height: 5.0,),
                                Text("Publicado: "+_formatPublicacion.format(DateTime.fromMillisecondsSinceEpoch(widget.publicacionTrabajoAlgolia.fechaCreacionAlgolia*1000)))
                              ],
                              crossAxisAlignment: CrossAxisAlignment.start,
                            ),
                          ),
                        ),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: <Widget>[
                                Text("DESCRIPCIÓN",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.indigo),),
                                SizedBox(height: 5.0,),
                                Text(widget.publicacionTrabajoAlgolia.descripcion)
                              ],
                              crossAxisAlignment: CrossAxisAlignment.start,
                            ),
                          ),
                        ),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: <Widget>[
                                Text("HABILIDADES NECESARIAS",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.indigo),),
                                SizedBox(height: 5.0,),
                                Text(widget.publicacionTrabajoAlgolia.habilidadesNecesarias)
                              ],
                              crossAxisAlignment: CrossAxisAlignment.start,
                            ),
                          ),
                        )
                      ],
                    );
              }
            }
          },
        ),
      )
    );
  }
}