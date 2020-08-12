import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path/path.dart';
import 'package:image/image.dart' as imageLib;
import 'package:image_picker/image_picker.dart';
import 'package:photofilters/photofilters.dart';
import 'package:wizart/filters/kalumba_filter.dart';
import 'package:wizart/filters/martha_filter.dart';
import 'package:wizart/filters/wizard_filter.dart';
import 'package:wizart/ui/filter_page.dart';
import 'package:giffy_dialog/giffy_dialog.dart';

class WizartPage extends StatefulWidget {
  WizartPage({Key key}) : super(key: key);

  @override
  _WizartPageState createState() => _WizartPageState();
}

class _WizartPageState extends State<WizartPage> {
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
    filters = filters + presetFiltersList + presetConvolutionFiltersList;
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

  saveImage() {}

  Widget _getFAB(context) {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 22),
      backgroundColor: Colors.deepPurple,
      visible: true,
      curve: Curves.bounceIn,
      children: [
        // FAB 1
        SpeedDialChild(
            child: Icon(Icons.save),
            backgroundColor: Colors.greenAccent,
            onTap: () {
              if (imageFile != null) {
                GallerySaver.saveImage(imageFile.path);
                showDialog(
                    context: context,
                    builder: (_) => AssetGiffyDialog(
                          image: Image.asset('assets/save.gif'),
                          title: Text(
                            'ALRIGHT !!!',
                            style: TextStyle(
                                fontSize: 22.0, fontWeight: FontWeight.w600),
                          ),
                          description: Text(
                            'Fichero guardado en carrete ...',
                            textAlign: TextAlign.center,
                            style: TextStyle(),
                          ),
                          entryAnimation: EntryAnimation.DEFAULT,
                          onlyOkButton: true,
                          onOkButtonPressed: () {
                            setState(() {
                              imageFile = null;
                            });
                            Navigator.pop(context);
                          },
                        ));
              } else {
                showDialog(
                    context: context,
                    builder: (_) => AssetGiffyDialog(
                          image: Image.asset('assets/no-save.gif'),
                          title: Text(
                            'WHAT !!!',
                            style: TextStyle(
                                fontSize: 22.0, fontWeight: FontWeight.w600),
                          ),
                          description: Text(
                            'No hay nada que salvar ...',
                            textAlign: TextAlign.center,
                            style: TextStyle(),
                          ),
                          entryAnimation: EntryAnimation.DEFAULT,
                          onlyOkButton: true,
                          onOkButtonPressed: () {
                            setState(() {
                              imageFile = null;
                            });
                            Navigator.pop(context);
                          },
                        ));
              }
            },
            label: 'Save',
            labelStyle: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black,
                fontSize: 16.0),
            labelBackgroundColor: Colors.greenAccent),
        // FAB 2
        SpeedDialChild(
            child: Icon(Icons.get_app),
            backgroundColor: Colors.blue,
            onTap: () {
              setState(() {
                getImage(context);
              });
            },
            label: 'Load',
            labelStyle: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black,
                fontSize: 16.0),
            labelBackgroundColor: Colors.blue),
        // FAB 3
        SpeedDialChild(
            child: Icon(Icons.exit_to_app),
            backgroundColor: Colors.red,
            onTap: () {
              setState(() {});
            },
            label: 'Exit App',
            labelStyle: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black,
                fontSize: 16.0),
            labelBackgroundColor: Colors.red)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.white,
      body: Center(
        child: Container(
          margin: EdgeInsets.all(MediaQuery.of(context).size.height * 0.04),
          padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.04),
          constraints: BoxConstraints.expand(),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                imageFile == null
                    ? Card(
                        semanticContainer: true,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: Image.asset(
                          'assets/image-placeholder-vertical.jpg',
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
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _getFAB(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
