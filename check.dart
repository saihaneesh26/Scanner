import 'dart:io';
import 'package:flutter/services.dart';
import 'package:edge_detection/edge_detection.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scanner',
      theme: ThemeData(
        primaryColor: Colors.red[400],
      ),
      home: MyHomePage(title: 'Scan'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

var msg='';
var new_pdf = new PdfDocument();
final double height = PdfPageSize.a4.height.toDouble();
final double width = PdfPageSize.a4.width.toDouble();
int new_pages = 0;
int num_pages=0;
var file;
var file_name='';

TextEditingController c1 = new TextEditingController();
TextEditingController c2 = new TextEditingController();

get_img(int index,String source)async
{
  setState(() {
    msg='getting image';
  });
  var el;
  if(source=='camera'){ 
    el = await EdgeDetection.detectEdge;
  }
  else{
    final add_img = await FilePicker.platform.pickFiles(type: FileType.image);
    el = add_img.files.first.path;
  }
    final sr= File(el).readAsBytesSync();
    final add_img_file = PdfBitmap(sr);
    new_pdf.pages.insert(index);
    final edit= new_pdf.pages[index];
    final c =Offset.zero;
    edit.graphics.drawImage(add_img_file, Rect.fromLTWH(0, 0,new_pdf.pages[0].getClientSize().width ,new_pdf.pages[0].getClientSize().height));
  setState(() {
    isLoading=false;
  });
}


save()async{
    setState(() {
      msg='Downloading...';
    });
                
  final pat = await getExternalStorageDirectory();
            var final_path = c1.text==''?'${DateTime.now().microsecondsSinceEpoch}s.pdf':'${c1.text}.pdf';
                // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("creating...."),));
                  await File('${pat.path}/${final_path}').writeAsBytes(new_pdf.save());
                    setState(() {
                    isLoading=false;
                  });
                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Saved at ${pat.path}/${final_path}"),));
}

bool isLoading=false;
final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return isLoading==true?
    Scaffold(
      appBar: AppBar(title: Text('Please wait'),),
      body: Center(
        child: Center(child: 
      Column(children:[CircularProgressIndicator(),
      Text("$msg.."),
      ] ),
        ),
      ),
    )
    :Scaffold(
      appBar: AppBar(
       title: Text(widget.title),actions:<Widget> [
        PopupMenuButton(itemBuilder: (itemBuilder){
          return {''}.map((String choice){
            return PopupMenuItem(child: GestureDetector(child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(1),
              decoration: BoxDecoration(),
              child: Row(
              children: [
              //  Icon(Icons.camera_alt,color: Colors.black,),
                Text('ntg yet☺')
                ],
                ),
                ),onTap: ()async{
            },));
          }).toList();
        })
      ],
      ),
      body: SingleChildScrollView(
        physics: ScrollPhysics(),
        child: Container(
          padding: EdgeInsets.all(5),
          child: Column(
            children:[
              TextFormField(
                controller: c1,
                decoration: InputDecoration(labelText: "Name",hintText: '.pdf',contentPadding: EdgeInsets.all(1),border: OutlineInputBorder()),
              )
              ,ElevatedButton(child:Text("select images") ,onPressed: () async{
              setState(() {
                isLoading=true;
              });
            final images = await FilePicker.platform.pickFiles(type: FileType.image,allowMultiple: true);  
            final pdf = PdfDocument();
            pdf.pageSettings.setMargins(0);
            if(images!=null)
              { 
              var final_path ='';
                images.files.forEach((element) async
                { 
                 
                  final i = element.path;
                  final image = PdfBitmap(
                    File(i).readAsBytesSync(),
                  );
                  final new_ =pdf.pages.add();
                  new_.graphics.drawImage(image, Rect.fromLTWH(10,10, pdf.pages[0].getClientSize().width,pdf.pages[0].getClientSize().height));
              }); final pat = await getExternalStorageDirectory();
                    try{
                      final_path =c1.text==''?pat.path+'/${DateTime.now().millisecondsSinceEpoch.ceil()}.pdf':pat.path+'/${c1.text}.pdf';
                      final file = File(final_path);
                      await file.writeAsBytes(pdf.save());
                      setState(() {
                        isLoading=false;
                      });
                    }catch(e)
                    { 
                      setState(() {
                        isLoading=false;
                      });  
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("error ${e.toString()}"),));
                      print(e.toString());
                      pdf.dispose();
                    
                    }
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("saved to ${final_path}"),));
                    pdf.dispose();
                }
              else{
                setState(() {
                  isLoading= false;
                });
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("something is wrong"),));   
                  pdf.dispose();    
              }
              
              },),

              ElevatedButton(onPressed: () async{
                setState(() {
                  isLoading=true;
                  msg='getting pdf';
                });
                 try{
                  file = await FilePicker.platform.pickFiles(type: FileType.custom,allowedExtensions:['pdf'],allowMultiple: false);
                  setState(() {
                    file_name = file.files.first.name;
                  });
                   
                  if(file!=null)
                  {
                  final f = File(file.files.first.path);
                 
                  new_pdf = PdfDocument(inputBytes: f.readAsBytesSync());
                  new_pdf.pageSettings.setMargins(0);
                  num_pages = new_pdf.pages.count;
                   setState(() {
                     msg='number of pages $num_pages';
                   });              
                  print("num $num_pages");
                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$num_pages"),));
                  }
                  setState(() {
                      isLoading=false;
                  });
                }catch(e)
                {
                  setState(() {
                    isLoading=false;
                  });
                  print("error manual"+e.toString());
                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${e.toString()}"),));
                }
                
     }, child: Text("select PDF to edit")),
     Text('selected pdf : $file_name'),
     TextFormField(
       key: _formKey,
        controller: c2,
        keyboardType: const TextInputType.numberWithOptions(signed: false,decimal: false),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(labelText: 'Insert at index',border: OutlineInputBorder()),
     ),

     ElevatedButton(onPressed: 
     ()async{
       if(num_pages<=0){
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("select pdf"),));
       }else{
    try{
      setState(() {
           isLoading=true;
         });
        final at =int.parse(c2.text);
        final index = at>0&&at<num_pages+1?at:1;
        await get_img(index-1,'gallery');
    }
    catch(e)
    {
        setState(() {
          isLoading=false;
        });
        print(e.toString());
    }
        c2.clear();
        setState(() {
           isLoading=false;
           new_pages++;
         });
      }    }, child: Text("ADD through gallery"),),
     ElevatedButton(onPressed: 
     ()async{
       if(num_pages<=0){
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("select pdf"),));
       }else{
    try{ 
      setState(() {
          isLoading=true;
      });
      final at =int.parse(c2.text);
      final index = at>0&&at<num_pages+1?at:1;
      await get_img(index-1,'camera');
    }
    catch(e)
    {
        setState(() {
          isLoading=false;
        });
        print(e.toString());
    }
        c2.clear();
        setState(() {
           isLoading=false;
           new_pages++;
         });
   } }, child: Text("ADD through camera"),),


     ElevatedButton(onPressed: ()async{
       if(num_pages<=0){
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("select pdf"),));
       }else
        {try{ 
          setState(() {
            isLoading=true;
          });
          final index =int.parse(c2.text);
          final at = index>0&&index<=num_pages?index-1:-1;
          if(at!=-1){
            new_pdf.pages.removeAt(at);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Removed ${c2.text} page"),));
            setState(() {
              num_pages--;
            });
          }
          else
            {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Can't Remove ${c2.text} page"),));
            }
          setState(() {
            isLoading=false;
          });
          }
        catch(e)
        {
          setState(() {
            isLoading=false;
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${e.toString()}"),));
        }
      }
     }, child: Text('Remove Page')),
     ElevatedButton(onPressed: ()async{
       if(num_pages<=0){
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("select pdf"),));
       }else
         {
        try{
          setState(() {
           isLoading=true;
           msg ='generating pdf';
         });
           
          await save();
          }catch(e){
            setState(() {
              isLoading=false;
            });
           print(e.toString());
         }
        setState(() {
          new_pages=0;
          isLoading=false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Saved"),));
        }
     }, child: Text("Generate")),

        Text("total pages $num_pages"),
        //file==null?Text('g'):file
            ]),
        
        ),
      )

    );
  }
}
