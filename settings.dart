import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scanneru/drawer.dart';
import 'package:scanneru/generate.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatelessWidget
{
  @override
  Widget build(BuildContext context)
  {
    return MaterialApp(
      theme: ThemeData(primaryColor: Colors.orange[400]),
      home: SettingsHome(),
    );
  }
}

class SettingsHome extends StatefulWidget
{
  @override
  SettingsHomeState createState() => SettingsHomeState();
}

class SettingsHomeState extends State<SettingsHome>
{
  TextEditingController c1 = new TextEditingController();
  static String text ="Advanced Scanner";
  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      drawer: WidgetDrawer(),
      appBar: AppBar(actions: [],title: Text("Settings"),),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.all(3),
        margin: EdgeInsets.all(1),
        child: Column(
          mainAxisAlignment:MainAxisAlignment.start,
          children: [
          Text("Enter your name to display as footer in generated PDF's"),
          SizedBox(height: 10,),
          TextField(
            controller: c1,
            decoration: InputDecoration(hintText: "Name",labelText: "Name"),
          ),
          SizedBox(height: 10,),
          ElevatedButton(onPressed: ()async{
                try {
                  SharedPreferences _prefs = await SharedPreferences.getInstance();
                  await _prefs.setString("name", c1.text.toString());
                  // await _prefs.setString("choice1", choice1);
                  setState(() {
                    Generater.footerc = "Scanned By "+c1.text.toString();
                    Generater.footere = "Edited By "+c1.text.toString();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Saved")));
                } on Exception catch (e) {
                  print(e);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error in saving ${e.toString()}")));
                }
              }, child: Text("Save"))
        ],),
      ),
    );
  }
}