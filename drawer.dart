import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scanneru/CreatePdf.dart';
import 'package:scanneru/generate.dart';
import 'package:scanneru/main.dart';
import 'package:scanneru/settings.dart';
import 'package:scanneru/shuffle.dart';


Widget WidgetDrawer()
{
  List<String> name = ["Home","Create PDF","Edit PDF","Settings"];
  List<Icon> icons = [Icon(Icons.home),Icon(Icons.picture_as_pdf),Icon(Icons.edit,),Icon(Icons.settings)];
  List routes = [MyApp(),CreatePdf(),Shuffle(),Settings()]; 
  Generater.list.clear();
  return Drawer(
    child: Column(
      children: [
        Container(
          child: SafeArea(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 30,horizontal: 10),
              margin: EdgeInsets.all(4),
              child: Text("Hello User",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
              ),
          ),
          width: double.infinity,
          height: 150,
          decoration: BoxDecoration(color: Colors.orange[400]),
          
          ),
        Expanded(
          child: ListView.builder(itemBuilder: (context,index){
            return GestureDetector(
              child: Container(
                padding: EdgeInsets.all(4),
                margin: EdgeInsets.all(4),
                decoration: BoxDecoration(border: Border.all(width: 1)),
                child: Row(children: [
                  icons[index],
                  SizedBox(width: 10,),
                  Text(name[index],style:TextStyle(fontSize: 20,fontWeight: FontWeight.w400) ,),
                ],),
                ),
              onTap: ()async{
                var dir = await getExternalStorageDirectory();
  var list = dir!.path.split("/");
  var finalpath ="";
  bool flag = true;
  list.forEach((element) { 
    if(element=="Android")
    {
      flag = false;
      finalpath+="Scanner";
    }
    if(flag)
    {
      finalpath+=element+"/";
    }
  });  
   try{
    var d = Directory(finalpath);
    
    MyAppHomeState.dirpath.clear();
    MyAppHomeState.files.clear();
  await for(var file in d.list(recursive: true,followLinks: false))
  {
    var l = file.path.split("/");
    MyAppHomeState.dirpath.add(file.path);
    MyAppHomeState.files.add(l[l.length-1]);
  }
  }
  catch(e)
  {
    print(e);
  }
                Navigator.push(context,MaterialPageRoute(builder: (context)=>routes[index]));
              },
            );
          },itemCount: name.length,),
        ),
      ],
    ),
  );
}