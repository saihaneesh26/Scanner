import 'dart:io';
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
var num_pages=0;

TextEditingController c1 = new TextEditingController();
TextEditingController c2 = new TextEditingController();

get_img(int index)async
{
  setState(() {
    msg='getting image';
  });
  final add_img = await FilePicker.platform.pickFiles(type: FileType.image);
    final el = add_img.files.first.path;
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
}


bool isLoading=false;
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
       title: Text(widget.title),
      ),
      body: Container(
        child: Column(
          children:[
            TextFormField(
              controller: c1,
              decoration: InputDecoration(labelText: "Name",hintText: '.pdf'),
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
              images.files.forEach((element) async
              { 
                var final_path ='';
                final i = element.path;
                final image = PdfBitmap(
                  File(i).readAsBytesSync(),
                );
                final new_ =pdf.pages.add();
                new_.graphics.drawImage(image, Rect.fromLTWH(10,10, pdf.pages[0].getClientSize().width,pdf.pages[0].getClientSize().height));
            }); final pat = await getExternalStorageDirectory();
                  try{
                    final file = c1.text==''?File("${pat.path}/${DateTime.now().millisecondsSinceEpoch.ceil()}.pdf"):File("${pat.path}/${c1.text}.pdf");
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
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("saved to ${pat.path}"),));
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
                final file = await FilePicker.platform.pickFiles(type: FileType.custom,allowedExtensions:['pdf'],allowMultiple: false);
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
     TextField(
       controller: c2,
       decoration: InputDecoration(labelText: 'Insert at index',),
     ),

     ElevatedButton(onPressed: 
     ()async{
       setState(() {
         isLoading=true;
       });
    try{
      final at =int.parse(c2.text);
      final index = at>0&&at<num_pages+1?at:1;
      await get_img(index-1);
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
     }, child: Text("ADD"),),

     ElevatedButton(onPressed: ()async{
       setState(() {
         isLoading=true;
         msg ='generating pdf';
       });
         
      try{
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
     }, child: Text("Generate")),

     ElevatedButton(onPressed: ()async{
      try{ 
        setState(() {
          isLoading=true;
        });
        new_pdf.pages.removeAt(int.parse(c2.text));
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Removed ${c2.text} page"),));
           setState(() {
             isLoading=false;
             num_pages--;
           });
        }
      catch(e)
      {
        setState(() {
          isLoading=false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${e.toString()}"),));
      }
     }, child: Text('Remove Page')),

      Text("new pages $new_pages"),
          ]),
      
      )

    );
  }
}
