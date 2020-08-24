import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:getflutter/getflutter.dart';
import 'package:kilimosalama/src/authentication.dart';
import 'package:kilimosalama/src/firestore.dart';
import 'package:kilimosalama/src/main/models/user_model.dart';
import 'reports/soil_reports.dart';
import 'reports/weather_reports.dart';
import 'package:google_fonts/google_fonts.dart';
import 'plant_disease/instructions.dart';
import 'package:provider/provider.dart';
import 'package:kilimosalama/src/API.dart';
import 'package:cached_network_image/cached_network_image.dart';

const CURVE_HEIGHT = 120.0;
const AVATAR_RADIUS = CURVE_HEIGHT * 0.32;
const AVATAR_DIAMETER = AVATAR_RADIUS * 2;

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return MaterialApp(
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(
        title: 'Home',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  var data;
  var sensorReading;
  
  
   @override
  void initState() {
    super.initState();
      _configureFirestoreOfflinePersistence();
  }

    _configureFirestoreOfflinePersistence() {
    Firestore.instance.settings(persistenceEnabled: false);
    }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.greenAccent[700],
        title: Text(
          'Welcome to Kilimo Salama ',
          style: GoogleFonts.aBeeZee(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<User>(
        stream: FirestoreService(uid:uid).userData,
        builder: (context, snapshot) {
          if(snapshot.hasData){

            User user = snapshot.data;

            return new Stack(
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Container(
                          margin: EdgeInsets.only(top: 2.0),
                          width: double.infinity,
                          height: AVATAR_DIAMETER,
                          padding: EdgeInsets.all(10),
                          child: Container(
                            decoration: new BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.greenAccent[700],
                            ),
                            child: new Icon(
                              Icons.home,
                              color: Colors.white,
                              size: AVATAR_RADIUS,
                            ),
                          )),
                      _buildTitle(),
                      SizedBox(
                        height: 20,
                      ),
                      _sensorButton(user, context),
                      SizedBox(
                        height: 20,
                      ),
                      _buildCard(),
                      SizedBox(
                        height: 60,
                      ),

                      // _healthCheck(),
                      SizedBox(
                        height: 20.0,
                      ),
                    ],
                  ),
                ),
              ),
              _healthButton(),
            ],
          );
          }
           else{
                                return Center(child: CircularProgressIndicator());
                              }
          
        }
      ),
    );
  }

   Widget _sensorButton( User user, BuildContext context) {
    return FlatButton.icon(
      color: Colors.green,
      onPressed: () async {
        // adb reverse tcp:5000 tcp:5000;
        data = await Getdata('http://127.0.0.1:5000/api?Farmer_Name=' + user.name + '&Farmer_Uid=' + user.uid );
        showDialog(context: context, builder: (context) => _sensorPopUp());
      }, 
      icon: Icon(
        Icons.autorenew,
        color: Colors.white
        ), 
      label: Text(
        "Activate Sensor",
        style: TextStyle(
          color: Colors.white
        )
        )
      );
  }


  Widget _sensorPopUp(){        
        return StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
                  .collection('sensors')
                  .orderBy('time', descending: true)
                  .limit(1)
                  .snapshots(includeMetadataChanges: true),
                  // .first,
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if(snapshot.hasData){
              sensorReading = snapshot.data.documents;
              // sensorReading.forEach((doc) => print(doc['soil_moisture']));
               return Center(
                 child: ListView.builder(
                   shrinkWrap: true,
                  itemCount: sensorReading.length ,
                  itemBuilder: (context, index) =>
                    Center(
                      child: Dialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)
                      ),
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      child: Center(
                        child: Container(
                          alignment: Alignment.center,
                            height: 130,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.all( Radius.circular(12))
                            ),
                            child: Column(
                              children: <Widget>[
                                 Container(
                                   height: 40,
                                   width: double.infinity,
                                    decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))
                                  ),
                                   child: Padding(
                                     padding: const EdgeInsets.all(8.0),
                                     child: Text(
                                        'SENSOR READING ',
                                        textAlign: TextAlign.center, 
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.white)
                                            ),
                                   ),
                                 ),
                                Container(
                                  margin: EdgeInsets.all(8),
                                  child: Table(
                                    border: TableBorder(
                                      top: BorderSide(color: Colors.grey, width: 1), 
                                      bottom: BorderSide(color: Colors.grey, width: 1)
                                        ),
                                    children: [
                                      TableRow(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                            'Soil_Moisture : ',
                                            textAlign: TextAlign.center, 
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0, color: Colors.grey)
                                        ),
                                          ),
                                         Padding(
                                           padding: const EdgeInsets.all(8.0),
                                           child: Text(
                                            // 'Value',
                                            sensorReading[index]['soil_moisture'].toString(),
                                            textAlign: TextAlign.center, 
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0)
                                        ),
                                         ),
                                        ]
                                      ),
                                      TableRow(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                            'Ph: ',
                                            textAlign: TextAlign.center, 
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0, color: Colors.grey)
                                        ),
                                          ),
                                         Padding(
                                           padding: const EdgeInsets.all(8.0),
                                           child: Text(
                                            // 'Value',
                                            sensorReading[index]['pH'].toString(),
                                            textAlign: TextAlign.center, 
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0)
                                        ),
                                         ),
                                        ]
                                      )
                                    ],
                                  ),
                                ),
                              ]
                            )
                        ,),
                      ),
                      ),
                    ),
                 ),
               );
            }
                     else{
                                return Center(child: CircularProgressIndicator());
                              }
          }
        );
      }

  Widget _healthButton() {
    return Positioned(
       bottom: 5.0,
      right: 4.0,
      child: FloatingActionButton.extended(
        label: Text('Plant \nHealth'),
        icon: Icon(Icons.camera_enhance),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        tooltip: 'Health',
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => InstrucPage()));
        },
      ),
    );
  }

  Widget _buildTitle() {
    return Container(
      child: Text(
        'Home',
        style: GoogleFonts.aBeeZee(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildCard() {
    return Column(
      children: <Widget>[
        //for soil report
        GFCard(
          height: 400,
          boxFit: BoxFit.cover,
          image: Image(
              image: CachedNetworkImageProvider(
                  'https://firebasestorage.googleapis.com/v0/b/kilimo-salama.appspot.com/o/images%2Fsoil.jpg?alt=media&token=503a3936-53cc-44d0-938c-e91959033155')),
          title: GFListTile(
            title: Center(
              child: Text(
                'Soil reports',
                style: GoogleFonts.aBeeZee(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          content: Text(
            "Click here to view your soil reports",
            style: GoogleFonts.aBeeZee(
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
          buttonBar: GFButtonBar(
            children: <Widget>[
              GFButton(
                color: Colors.greenAccent[700],
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SoilReportPage()));
                },
                text: 'View Report',
              ),
            ],
          ),
        ),

        SizedBox(
          height: 20,
        ),

        //for weather report
        GFCard(
          boxFit: BoxFit.cover,
          image: Image(
              image: CachedNetworkImageProvider(
                  'https://firebasestorage.googleapis.com/v0/b/kilimo-salama.appspot.com/o/images%2Fweather.jpg?alt=media&token=8c685cf8-6357-4599-8142-afe4f63d3692')),
          title: GFListTile(
            title: Center(
              child: Text(
                'Weather reports',
                style: GoogleFonts.aBeeZee(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          content: Center(
            child: Text(
              "Click here to view Weather reports",
              style: GoogleFonts.aBeeZee(
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          buttonBar: GFButtonBar(
            children: <Widget>[
              GFButton(
                color: Colors.greenAccent[700],
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => WeatherReportsPage()));
                },
                text: 'View Report',
              ),
            ],
          ),
        ),

        SizedBox(
          height:5,
        ),

      ],
    );
  }
}


