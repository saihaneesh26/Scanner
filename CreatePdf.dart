import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:scanneru/drawer.dart';
import 'dart:io';
import 'package:scanneru/generate.dart';
import 'package:scanneru/main.dart';
class CreatePdf extends StatelessWidget
{
  Widget build(BuildContext context)
  {
    return MaterialApp(
      theme: ThemeData(primaryColor: Colors.orange[400]),
      home: CreatePdfHome(),
    );
  }
}
class CreatePdfHome extends StatefulWidget{
  
  CreatePdfState createState() => CreatePdfState();
}

class CreatePdfState extends State<CreatePdfHome>{

  // final pdf = new pw.Document();
  bool isLoading = false;
  bool selected  = false;
  bool flag = true;
  bool alert = false;
  static var nameOfFile = DateTime.now().microsecondsSinceEpoch.toString()+".pdf";
  TextEditingController c1 = new TextEditingController();
static List<File> pathOfImages = [];
  @override
  Widget build(BuildContext context) {
    return isLoading?Center(child: CircularProgressIndicator(),):Scaffold(
      drawer: WidgetDrawer(),
      appBar: AppBar(actions: [],title: Text("Create from Images"),),
      body: Center(
        child: Container(
         child: selected?Text("Selected images: "):ElevatedButton(child: Text("Select Images"),onPressed: ()async{
           setState(() {
             isLoading = true;
           });
           try
           {
            await[ Permission.photos,Permission.manageExternalStorage].request().then((value)async{
            FilePickerResult? res = await FilePicker.platform.pickFiles(type: FileType.custom,allowedExtensions: ['png','jpg','jpeg'],allowMultiple: true)??null;
              //get files path
              if(res!=null)
              {
                for(int index =0;index<res.files.length;index++)
                {
                  PlatformFile? image = res.files[index];
                  pathOfImages.add(File(image.path!));
                }//for each
                setState(() {
                  c1.text = nameOfFile;
                  alert= true;
                });
                Generater.generate();
                print("start");
                alert?showDialog(context: context, builder: (_){
                  return Container(
                    height: 250,
                    child: AlertDialog(
                    actions: [
                      TextButton(onPressed: ()async{
                              setState(() {
                                isLoading=true;
                                nameOfFile = c1.text;
                              });
                              Generater.save(nameOfFile);
                              setState(() {
                                isLoading=false;
                                alert=false;
                                Generater.list.clear();print("clear");
                              });
                               var dir = await getExternalStorageDirectory();
                                  var listd = dir!.path.split("/");
                                  var finalpath ="";
                                  bool flagd = true;
                                  listd.forEach((element) { 
                                    if(element=="Android")
                                    {
                                      flagd = false;
                                      finalpath+="Scanner";
                                    }
                                    if(flagd)
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
                              Navigator.of(context,rootNavigator: true).pop();
                              print("end");
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Saved")));
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>MyApp()));
                            }, child: Text("Rename and save")),
                    ],
                    content:Container(
                      height: 200,
                      width: double.infinity,
                      child: 
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("Rename file"),
                            TextField(
                              controller: c1,
                              decoration: InputDecoration(hintText: "Name.pdf",labelText: "Name"),
                            )
                            ]
                            ),
                    ),
                ),
                  );
                }):SizedBox();
              setState(() {
                selected = true;
              });
              }
              else //res is null
              {
                // Generater.list.clear();
                print("null res");
              }
            });//permission       
           }
           catch(e)
           {
            //  Generater.list.clear();
             setState(() {
               isLoading = false;
               selected = false;
             });
             print(e);
           }
           setState(() {
             isLoading = false;
           });
         // Navigator.push(context, MaterialPageRoute(builder: (context)=>  MyApp()));
         },),
     ),
      ),
    );
  }
}