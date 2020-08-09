import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path/path.dart';
import 'package:image/image.dart' as imageLib;
import 'package:image_picker/image_picker.dart';
import 'package:photofilters/photofilters.dart';
import 'package:wizart/filters/kalumba_filter.dart';
import 'package:wizart/filters/martha_filter.dart';
import 'package:wizart/filters/wizard_filter.dart';
import 'package:wizart/ui/filter_page.dart';


class WizartPage extends StatefulWidget {
  WizartPage({Key key}) : super(key: key);

  @override
  _WizartPageState createState() => _WizartPageState();
}

class _WizartPageState extends State<WizartPage> {
  static final style = TextStyle(
      fontSize: 18,
      fontFamily: "Billy",
      fontWeight: FontWeight.w500,
      color: Colors.white);

  final _picker = ImagePicker();
  String fileName;
  File imageFile;

  List<Filter> filters = [];
  Filter wizard = new WizardFilter();
  Filter martha = new MarthaFilter();
  Filter kalumba = new KalumbaFilter();

  @override
  void initState() { 
    super.initState(); 
    filters = [wizard, kalumba, martha];
    filters = filters + presetFiltersList + presetConvolutionFiltersList ;
  }

  Future getImage(context) async {
    final pickedFile = await _picker.getImage(source: ImageSource.gallery);
    imageFile = File(pickedFile.path);
    fileName = basename(imageFile.path);
    var image = imageLib.decodeImage(imageFile.readAsBytesSync());
    image = imageLib.copyResize(image, width: 600);
    Map imagefile = await Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (context) => new FilterPage(
          title: Text("WizArt"),
          image: image,
          filters: filters,
          filename: fileName,
          loader: Center(child: CircularProgressIndicator()),
          fit: BoxFit.contain,
        ),
      ),
    );
    if (imagefile != null && imagefile.containsKey('image_filtered')) {
      setState(() {
        imageFile = imagefile['image_filtered'];
      });
      print(imageFile.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Container(
            margin: EdgeInsets.all(MediaQuery.of(context).size.height * 0.03),
            padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.03),
            constraints: BoxConstraints.expand(),
            decoration: BoxDecoration(
                image: DecorationImage(
              image: AssetImage('assets/1.png'),
              fit: BoxFit.scaleDown,
            )),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  MaterialButton(
                    minWidth: double.infinity,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        side: BorderSide(color: Colors.white)),
                    color: Colors.lightBlueAccent,
                    textColor: Colors.lightBlueAccent,
                    padding: EdgeInsets.symmetric(vertical: 5),
                    onPressed: () => getImage(context),
                    child: Text(
                      "  Salir ",
                      style: style,
                    ),
                  ),
                  imageFile == null
                      ? Card(
                          semanticContainer: true,
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: Image.asset(
                            'assets/1.png',
                            fit: BoxFit.contain,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 5,
                          margin: EdgeInsets.all(10),
                        )
                      : Card(
                          semanticContainer: true,
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: Image.file(
                            imageFile,
                            fit: BoxFit.fill,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 5,
                          margin: EdgeInsets.all(5),
                        ),
                  imageFile == null
                      ? MaterialButton(
                          minWidth: double.infinity,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              side: BorderSide(color: Colors.white)),
                          color: Colors.pinkAccent,
                          textColor: Colors.pinkAccent,
                          padding: EdgeInsets.symmetric(vertical: 5),
                          onPressed: () => getImage(context),
                          child: Text(
                            "  Cargar imagen ",
                            style: style,
                          ),
                        )
                      : Column(
                        children: <Widget>[
                          MaterialButton(
                          minWidth: double.infinity,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              side: BorderSide(color: Colors.white)),
                          color: Colors.pinkAccent,
                          textColor: Colors.pinkAccent,
                          padding: EdgeInsets.symmetric(vertical: 5),
                          onPressed: () => getImage(context),
                          child: Text(
                            "  Cargar imagen ",
                            style: style,
                          ),
                        ),
                          MaterialButton(
                              minWidth: double.infinity,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  side: BorderSide(color: Colors.white)),
                              color: Colors.pinkAccent,
                              textColor: Colors.pinkAccent,
                              padding: EdgeInsets.symmetric(vertical: 5),
                              onPressed: () {
                                GallerySaver.saveImage(imageFile.path);
                                setState(() {
                                  imageFile = null;
                                });
                                Scaffold.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(SnackBar(
                                    content: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text('  Imagen guardada en Galería... '),
                                      ],
                                    ),
                                  ));
                              },
                              child: Text(
                                "  Guardar  ".toUpperCase(),
                                style: style,

                              ),
                            ),
                        ],
                      ),
                ],
              ),
            ),
          ),
        ),
    );
  }
}
