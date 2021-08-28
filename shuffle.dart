import 'dart:io';
import 'dart:typed_data';
import 'package:scanneru/drawer.dart';
import 'generate.dart';
import 'package:flutter/material.dart';
import 'package:native_pdf_renderer/native_pdf_renderer.dart';
import 'package:file_picker/file_picker.dart';
class Shuffle extends StatelessWidget
{
  @override
  Widget build(BuildContext context)
  {
    return MaterialApp(
      theme: ThemeData(primaryColor:Colors.orange[400]),
      home: ShuffleHome(), 
    );
  }
}
class ShuffleHome extends StatefulWidget
{
  @override
  ShuffleHomeState createState() => ShuffleHomeState();
}

class ShuffleHomeState extends State<ShuffleHome>
{
  bool isLoading = false;
  bool edited = false;
  var nameOfFile ;
  bool loaded = false;
  // List pageslist = [];
  // int itemcount =0;
  String newName = "";
  List highlight =[];
  List<Uint8List> pagesBytes = [];
  int prev1 = 0,prev2=0;
  String request = "";
  ScrollController c = new ScrollController();
  ScrollController c5 = new ScrollController();
  TextEditingController c1 = new TextEditingController();//swap1
  TextEditingController c2 = new TextEditingController();//swap2
  TextEditingController c3 = new TextEditingController();//add
  TextEditingController c4 = new TextEditingController();//remove
  @override
  Widget build(BuildContext context)
  {
    return isLoading?Center(child: CircularProgressIndicator(),):Scaffold(
      drawer: WidgetDrawer(),
      appBar: AppBar(
        actions: [
        ],title: Text("Edit PDF"),),
      body: isLoading?
      Center(child: CircularProgressIndicator(),)
      :Container(
        child: Column(
          children:[ 
            ElevatedButton(onPressed: ()async{
            try {
              setState(() {
                isLoading = true;
                highlight.clear();
                pagesBytes.clear();
              });
             FilePickerResult? file = await FilePicker.platform.pickFiles(type: FileType.custom,allowMultiple: false,allowedExtensions: ['pdf']);
              if(file!=null)
              {
                setState(() {
                  nameOfFile = file.names.first.toString();
                });
                PdfDocument pdf = await PdfDocument.openFile(file.files.first.path!);
                for(var i=1;i<=pdf.pagesCount;i++)
                {
                  print("added: "+i.toString());
                  PdfPage page = await pdf.getPage(i);
                  var  a = await page.render(height: page.height.toInt()+1,width: page.width.toInt()+1);
                  pagesBytes.add(a!.bytes);
                  highlight.add(false);
                  page.close();
                }
                setState(() {
                    var name = nameOfFile.toString().split(".pdf");
                    var base = name[0];
                    newName = base+"_Edited.pdf";
                    // itemcount = pagesBytes.length;
                  isLoading = false;
                  loaded = true;
                });
              }
            }catch (e) {
              print(e);
            }
          },child: Text("Select New file"),),
          
          pagesBytes.length!=0?
          Container(
            margin: EdgeInsets.all(3),
            padding: EdgeInsets.all(3),
            decoration: BoxDecoration(border: Border.all(width: 1,color:Colors.black)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Radio(
                  value: "Add", groupValue: request, onChanged: (val)async{
                  setState(() {
                    request = val.toString();
                  });
                }),Text("Add"),
                Radio(value: "Remove", groupValue: request, onChanged: (val)async{
                  setState(() {
                    request = val.toString();
                  });
                }),Text("Remove"),
                Radio(value: "Shift", groupValue: request, onChanged: (val)async{
                  setState(() {
                    request = val.toString();
                  });
                }),Text("Shift"),
            ],)
            ):SizedBox(),
            //add
            request.toString()=="Add"?
            Container(
              padding: EdgeInsets.all(3),
              margin: EdgeInsets.all(3),
              decoration: BoxDecoration(border: Border.all(width: 1,color:Colors.black)),
              width: double.infinity,
              child:  Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      child: TextField(
                        controller: c3,
                        keyboardType: TextInputType.numberWithOptions(decimal: false,signed: false),
                        decoration: InputDecoration(labelText: "Add page at",hintText: "PageNo"),
                      ),
                    ),
                    ElevatedButton(onPressed: ()async{
                      setState(() {
                        isLoading=true;
                      });
                      try
                      {
                        int pos =int.parse(c3.text.toString());
                        if(pos>0)
                        {
                          int at = pos>pagesBytes.length+1?pagesBytes.length+1:pos-1;
                          var imagefile = await FilePicker.platform.pickFiles(allowMultiple: false,type: FileType.custom,allowedExtensions: ["png","jpg","jpeg"]);
                          if (imagefile!=null) {
                            Uint8List imagebytes = await File(imagefile.files.first.path!).readAsBytes();
                            
                            setState(() {
                              pagesBytes.insert(at, imagebytes);
                              highlight.insert(at,false);
                              c3.clear();print(pagesBytes.length);
                              //  itemcount = pagesBytes.length;
                              edited=true;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("added ${imagefile.names.first} at $pos")));
                          }
                          else
                          {
                            setState(() {
                              c3.clear();
                            });
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error in picking image")));
                          }
                        }
                        else
                        {
                          setState(() {
                            c3.clear();
                          });
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Enter valid pageNumber")));
                        }
      
                      }catch(e)
                      {
                        setState(() {
                          isLoading = false;
                          c3.clear();
                        });
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Enter page number")));
                        print(e);
                      }
                      setState(() {
                        isLoading=false;
                        c3.clear();
                      });
                    }, child: Text("Pick Image and Add")),
                  ],
                ),
            )
            :SizedBox(height: 0,),
            //Remove
            request.toString()=="Remove"?
            Container(
              padding: EdgeInsets.all(3),
              margin: EdgeInsets.all(3),
              decoration: BoxDecoration(border: Border.all(width: 1,color:Colors.black)),
              width: double.infinity,
              child:  Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      child: TextField(
                        controller: c4,
                        keyboardType: TextInputType.numberWithOptions(decimal: false,signed: false),
                        decoration: InputDecoration(labelText: "Remove pageNo",hintText: "PageNo"),
                      ),
                    ),
                    ElevatedButton(onPressed: ()async{
                      setState(() {
                        isLoading=true;
                      });
                      try
                      {
                        int pos =int.parse(c4.text.toString());
                        if(pos>0 && pos<=pagesBytes.length)
                        {
                          int at = pos-1;
                          setState(() {
                            pagesBytes.removeAt(at);
                            // print(pagesBytes.length);
                            highlight.removeAt(at);
                            // itemcount = pagesBytes.length;
                            edited=true;
                            c4.clear();
                          });
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Removed pageno $pos")));
                        }
                        else
                        {
                          setState(() {
                            c4.clear();
                          });
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Enter valid pageNumber")));
                        }
      
                      }catch(e)
                      {
                        setState(() {
                          c4.clear();
                          isLoading = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Enter page number")));
                        print(e);
                      }
                      setState(() {
                        c4.clear();
                        isLoading=false;
                      });
                    }, child: Text("Remove")),
                    
                  ],
                ),
            )
            :SizedBox(),
            //Shift
          request.toString()=="Shift"?Container(
             padding: EdgeInsets.all(3),
             margin: EdgeInsets.all(3),
             decoration: BoxDecoration(border: Border.all(width: 1)),
             width: double.infinity,
             child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
               crossAxisAlignment: CrossAxisAlignment.center,
               children: [
                Container(
                 width: 100,
                 height: 100,
                 child: 
                   TextField(
                       controller: c1,
                        onEditingComplete: (){
                          var value = c1.text;
                              setState(() {
                                try {
                                  if(value==null||value.length==0)
                                  {
                                    highlight[prev1]=false;
                                  }
                                  else if (int.parse(value)>0 && int.parse(value) <=pagesBytes.length) {
                                      highlight[int.parse(value)-1]=true;
                                      prev1 = int.parse(value);
                                    }
                                  else
                                  {
                                    highlight[prev1]=false;
                                  }
                                } on Exception catch (e) {
                                  highlight[prev1]=false;
                                  print(e);
                                }
                              });
                              },
                       decoration: InputDecoration(hintText: "From",labelText: "Shift Page From"),
                       keyboardType: TextInputType.numberWithOptions(decimal: false,signed: false),
                       ),),
                       SizedBox(width: 10,),
                       Icon(Icons.arrow_right_alt),
                       SizedBox(width: 10,),
                        Container(
                          width: 100,
                        height: 100,
                        child: 
                          TextField(
                            onEditingComplete: (){
                              var value = c2.text;
                              setState(() {
                                try {
                                  if(value==null||value.length==0)
                                  {
                                    highlight[prev2]=false;
                                  }
                                  else if (int.parse(value)>0 && int.parse(value) <= pagesBytes.length) {
                                      highlight[int.parse(value)-1]=true;
                                      prev2 = int.parse(value);
                                    }
                                  else
                                  {
                                    highlight[prev2]=false;
                                  }
                                } on Exception catch (e) {
                                  highlight[prev2]=false;
                                  print(e);
                                }
                              });
                              },
                              controller: c2,
                              decoration: InputDecoration(hintText: "To",labelText:"Shift To"),
                              keyboardType: TextInputType.numberWithOptions(decimal: false,signed: false),
                              ),
                          ),
                          SizedBox(width: 10,),
                        ElevatedButton(onPressed: ()async{
                          try {
                            if(c1.text.isNotEmpty && c2.text.isNotEmpty && 
                                int.parse(c1.text.toString())>0 && int.parse(c1.text.toString())<=pagesBytes.length &&
                                int.parse(c2.text.toString())>0 && int.parse(c2.text.toString())<=pagesBytes.length &&
                                int.parse(c1.text.toString()) != int.parse(c2.text.toString()))
                            {
                              setState(() {
                                isLoading = true;
                              });
                              
                              setState(() {
                                pagesBytes.insert(int.parse(c2.text.toString())-1, pagesBytes.removeAt(int.parse(c1.text.toString())-1));
                              });
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("successfully swapped page ${c1.text.toString()} with ${c2.text.toString()}")));
                              setState(() {
                                isLoading = false;
                                edited = true;
                                highlight[int.parse(c1.text.toString())-1]=false;
                                highlight[int.parse(c2.text.toString())-1]=false;
                                c1.clear();
                                c2.clear();
                                
                              });
                            }
                            else
                            {
                              setState(() {
                                isLoading=false;
                                highlight[int.parse(c1.text.toString())-1]=false;
                              highlight[int.parse(c2.text.toString())-1]=false;
                              c1.clear();
                              c2.clear();
                              });
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Enter Pagenumbers correctly")));
                            }
                          } catch (e) {
                            setState(() {
                              isLoading=false;
                                highlight[int.parse(c1.text.toString())-1]=false;
                              highlight[int.parse(c2.text.toString())-1]=false;
                              c1.clear();
                              c2.clear();
                              });
                            print(e.toString());
                          }
                        }, child: Text("Shift"))
             ],),
           ):SizedBox(),
           
           Container(
             width: double.infinity,
             padding: EdgeInsets.all(3),
             margin: EdgeInsets.all(3),
             decoration: BoxDecoration(border: Border.all(width: 1)),
             child: Column(
               mainAxisAlignment: MainAxisAlignment.start,
               children:[
                Text("$nameOfFile",overflow: TextOverflow.visible,style: TextStyle(fontSize: 20),),
                Text("pages: ${pagesBytes.length}",overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 20),),
                newName==""?SizedBox():Text("Creating New File as $newName "),
                edited?ElevatedButton(onPressed: ()async{
                      try {
                        setState(() {
                          isLoading = true;
                        });
                        Generater.generateedited(pagesBytes);
                        Generater.save(newName);
                        pagesBytes.clear();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Saved in Myfiles/Scanner")));
                        setState(() {
                          print("in");
                          edited = false;
                          pagesBytes.length=0;
                          request = "";
                          pagesBytes.clear();
                          newName="";
                          nameOfFile = "";
                          isLoading=false;
                        });
                      } on Exception catch (e) {
                        setState(() {
                          edited = false;
                          print("ex");
                          pagesBytes.length=0;
                          newName="";
                          nameOfFile="";
                          request = "";
                          pagesBytes.clear();
                          isLoading=false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to save")));
                        print(e);
      
                      }
                    }, child: Text("Save")):SizedBox(),
              ]),
           ),
          Container(
            child: Expanded(
              child: ListView.builder(
                 itemCount:pagesBytes.length.toInt(),
                 scrollDirection: Axis.vertical,
                 shrinkWrap: true,
                 physics: AlwaysScrollableScrollPhysics(),
                 itemBuilder: (context,index){
                   try {
                     print("index:"+index.toString());
                     print("len:"+pagesBytes.length.toString());
                   
                 return Container(
                    //  width: 100,
                    //  height: 100,
                    width: double.infinity,
                    padding: EdgeInsets.all(5),
                    margin: EdgeInsets.all(5).add(EdgeInsets.only(right: 4)),
                    decoration: BoxDecoration(border: Border.all(width: highlight[index]?3:1,color: highlight[index]?Colors.blueAccent:Colors.black)),
                     child: Column(
                       children: [
                         Text("Page :"+(index+1).toString()),
                         Image.memory(pagesBytes[index],width: 200,height: 200,),
                       ],
                     ),
                   );
                 } catch (e) {
                   print(e);
                     return SizedBox();
                   };
                //return Image.memory(pageslist[index].bytes,width: 100,height: 100,);
               }),
            ),
          )
          ],
          ),
      ),        
    );
  }
}