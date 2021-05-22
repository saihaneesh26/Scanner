import 'dart:io';
import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
//import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:file_picker/file_picker.dart';
import 'package:pdf_compressor/pdf_compressor.dart';
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
final new_pdf = new pw.Document();
List <pw.MemoryImage> all_pages = [];
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
    final sr=await File(el).readAsBytes();
    final add_img_file = pw.MemoryImage(sr);
    all_pages.insert(index,add_img_file);
  setState(() {
    isLoading=false;
  });
}


save()async{
 for(var i=0;i<all_pages.length;i++){
              await  new_pdf.addPage(pw.Page(build: (pw.Context c){
                         return pw.Center(child: pw.Image(all_pages[i]));
                       }));
                } 
  final pat = await getExternalStorageDirectory();
                var l= pat.path.split('/');
                // var final_path='';
                // for (var element in l){
                //   if(element!='Android')
                //     {
                //       final_path+=element+'/';
                //     }
                //     else if(element=='Android'){
                //       break;
                //     }
                // }
                //   final_path+='Download';
                //   final temp_path =pat.path+'/${DateTime.now().millisecondsSinceEpoch.ceil()}.pdf';
                //   if(c1.text=='')
                //   {
                //     final_path+='/${DateTime.now().millisecondsSinceEpoch}.pdf';
                //   }
                //   else{
                //     final_path+='/${c1.text}.pdf';
                //   }

             var temp_path = pat.path+'/${DateTime.now().millisecondsSinceEpoch.ceil()}.pdf';
            var final_path = c1.text==''?'/${DateTime.now().microsecondsSinceEpoch}s.pdf':'/${c1.text}.pdf';
                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("creating...."),));
                  await File(temp_path).writeAsBytes(await new_pdf.save());
                  setState(() {
                  msg='compressing...';
                });
                 // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("compressing..."),));
                 await PdfCompressor.compressPdfFile(temp_path, '${pat.path}/$final_path', CompressQuality.HIGH);
                  setState(() {
                  msg='deleting cache...';
                });
              //    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("deleting cache...."),));
                await File(temp_path).deleteSync(recursive: true);
                  print("compresses");
                  all_pages.clear();print(all_pages.length);
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
          final images = await FilePicker.platform.pickFiles(type: FileType.image);  
       // final images = await ImagePicker.platform.pickImage(source: ImageSource.gallery);
        final pdf = pw.Document(); 
       // final im = File(images.path);


          if(images!=null)
            {
              images.files.forEach((element) async { 
                   var final_path ='';
                 final i = element.path;
                final image = pw.MemoryImage(
                  File(i).readAsBytesSync(),
                );
              await  pdf.addPage(pw.Page(build: (pw.Context context) {
                    return pw.Center(child: pw.Image(image));
                     }));
                 final pat = await getExternalStorageDirectory();
                 var l= pat.path.split('/');
                for (var element in l){
                  if(element!='Android')
                    {
                      final_path+=element+'/';
                    }
                    else if(element=='Android'){
                      break;
                    }
                }
                  final_path+='Download';
                  try{
                  final file = c1.text==''?File("${pat.path}/${DateTime.now().millisecondsSinceEpoch.ceil()}.pdf"):File("${pat.path}/${c1.text}.pdf");
                  await file.writeAsBytes(await pdf.save());
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
                
                  }
                  
                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("saved to ${pat.path}"),));
            }
              );
            }
            else{
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("something is wrong"),));       
            }
            
            },),

            ElevatedButton(onPressed: () async{
              setState(() {
                isLoading=true;
                msg='getting pdf';
              });
              try{
                final file = await FilePicker.platform.pickFiles(type: FileType.custom,allowedExtensions:['pdf'],);
                setState(() {
                   msg='1';
                 });
                final f =File(file.paths.first);
                setState(() {
                   msg='2';
                 });
                 //final PdfDocument doc = PdfDocument(inputBytes: f.readAsBytesSync());
               PDFDocument doc = await PDFDocument.fromFile(f);
                 num_pages = doc.count;
                 setState(() {
                   msg='number of pages $num_pages';
                 });
                print("num $num_pages");
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$num_pages"),));
                for(var i=1;i<=num_pages;i++)
                {
                //  PDFPage page = await doc.get(page: i, );
                  final im = pw.MemoryImage( await File(page.imgPath,).readAsBytes());
                  all_pages.add(im);
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
      final index = at>0&&at<num_pages+2?at-1:0;
      await get_img(index);
    }
    catch(e)
    {
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
         print(e.toString());
       }
      setState(() {
        new_pages=0;
        isLoading=false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Saved in downloads"),));
     }, child: Text("Generate")),

     Text("new pages $new_pages"),
          ]),
      
      )

    );
  }
}
