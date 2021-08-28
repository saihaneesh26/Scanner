import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'CreatePdf.dart';
import 'main.dart';

class Generater{
  static var pdf ;
  static final list = CreatePdfState.pathOfImages;
 static final String header = "Advanced Scanner";
  static String footerc = "";
  static String footere = "";
static void generate()
{
  pdf=new pw.Document(); 

  try {
    for (var i=0;i<list.length;i++)
    {
      var item = list[i];
      final image = pw.MemoryImage(
                    File(item.path).readAsBytesSync()
                  );
      pdf.addPage(
        pw.MultiPage(
          maxPages: 1,
          margin: EdgeInsets.all(4),
          pageFormat: PdfPageFormat(PdfPageFormat.a4.width.toDouble()+20, PdfPageFormat.a4.height.toDouble()+120),
          // pageFormat: PdfPageFormat(width+10, 100+height),
          header: (_){
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("$header",textAlign: TextAlign.right,style: TextStyle(fontSize: 20)),
              ]
            );
          },
          footer: (_){
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("$footerc",textAlign: TextAlign.left,style: TextStyle(fontSize: 20)),
                Text("Page No: ${i+1}",textAlign: TextAlign.right),
              ]
            );
          },
          build: (_){
            return [
             Wrap(
                children: [
                 Container(
                    height: PdfPageFormat.a4.height,
                    width: PdfPageFormat.a4.width,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image:image,
                        fit: BoxFit.contain,
                      ),
                      // shape: BoxShape.circle,
                    ),
                  ) 
                ]
              )
            ];
          }
        ),
      );
    }
  } catch (e) {
    print(e);
  }

}

static void save(String name) async
{
    var filePath = await getExternalStorageDirectory();
    var finalPath = "";
    var list = filePath?.path.split('/');
    var flag = false;
    list!.forEach((element) {
      if(element=="Android") 
      {
        flag = true;
      }
      if(flag==false)
      {
        print(element);
        finalPath+=element.toString()+"/";
      }
    });
    print(finalPath);
    await ([Permission.manageExternalStorage,Permission.storage,Permission.photos].request().then((value)async {
    await  new Directory(finalPath+'Scanner/').create(recursive: true).then((value)async{
      await File(finalPath+"Scanner/$name").create(recursive: true).then((file)async {
        await file.writeAsBytes(await pdf.save());
      });
      await File(filePath!.path+"/$name").create(recursive: true).then((file)async {
        await file.writeAsBytes(await pdf.save());
      });
    });
    print("done");
    }));
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
}

  static void generateedited(List<Uint8List> pages)
  {
    pdf=new pw.Document(); 
    try {
      for(var i=0;i<pages.length;i++)
      {
        var image = pw.MemoryImage(pages[i]);
        pdf.addPage(
          pw.MultiPage(
            maxPages: 1,
            margin: EdgeInsets.all(4),
          pageFormat: PdfPageFormat(PdfPageFormat.a4.width.toDouble()+20, PdfPageFormat.a4.height.toDouble()+100),
          header: (_){
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("$header",textAlign: TextAlign.right,style: TextStyle(fontSize: 20)),
            ]
          );
        },
        footer: (_){
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("$footere",textAlign: TextAlign.left,style: TextStyle(fontSize: 20)),
              Text("Page No: ${i+1}",textAlign: TextAlign.right),
            ]
          );
        },
         build: (_){
            return [
             Wrap(
                children: [
                 Container(
                    height: PdfPageFormat.a4.height,
                    width: PdfPageFormat.a4.width,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image:image,
                        fit: BoxFit.contain,
                      ),
                      // shape: BoxShape.circle,
                    ),
                  ) 
                ]
              )
            ];
          }
        ),
      );
    }
    } catch (e) {
      print(e);
    }
  }

}