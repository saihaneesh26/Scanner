import 'package:flutter/material.dart';
import 'package:scanneru/drawer.dart';
import 'package:scanneru/generate.dart';
import 'package:scanneru/settings.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
try{
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  // SettingsHomeState.choice1 = (_prefs.getString("choice1")??"false");
  SettingsHomeState.text = _prefs.getString("name")??"Advanced Scanner";
  Generater.footerc = "Scanned By "+SettingsHomeState.text;
  Generater.footere = "Edited By "+SettingsHomeState.text;
  print(SettingsHomeState.text.toString());
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
  runApp(MyApp());
}

class MyApp extends StatelessWidget
{

  Widget build(BuildContext context)
  {
    return MaterialApp(
      theme: ThemeData(primaryColor: Colors.orange[400]),
      home: MyAppHome(),

    );
  }
}
class MyAppHome extends StatefulWidget{
  
  MyAppHomeState createState() => MyAppHomeState();
}

class MyAppHomeState extends State<MyAppHome>
{
  static List<String> files = [];
  static List<String> dirpath = [];
  @override
  void initState()
  {
    super.initState();
  }

  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return isLoading?Center(child: CircularProgressIndicator(),):Scaffold(
      drawer: WidgetDrawer(),
      appBar: AppBar(actions: [],title: Text("Home"),),
      body: files.length==0?Center(child: Text("No files to share"),) :Container(
        child: Column(
          children: [
            Text("Files in Scanner",style: TextStyle(fontSize: 30,),),
            Expanded(
              child: ListView.builder(itemCount: dirpath.length,itemBuilder: (_,index){
                try {
                  return Container(
                    padding: EdgeInsets.all(3),
                    margin: EdgeInsets.all(3),
                    decoration: BoxDecoration(border: Border.all(width: 1)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            child: Text(files[index],overflow: TextOverflow.ellipsis,maxLines: 2,style:TextStyle(fontSize: 15))
                          ),
                        ),
                        IconButton(onPressed: ()async{
                          Share.shareFiles([dirpath[index]],text: "I am sharing File ${files[index]} made from Advanced Scanner App");
                        }, icon: Icon(Icons.share))
                      ],
                    ),
                  );
                } on Exception catch (e) {
                  return Container();
                }
              }),
            ),
          ],
        ),
      ),
    );
  }
}