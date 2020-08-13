import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imageLib;
import 'package:path_provider/path_provider.dart';
import 'package:photofilters/filters/filters.dart';
import 'package:wizart/ui/top_bar.dart';

///The PhotoFilterSelector Widget for apply filter from a selected set of filters
class FilterPage extends StatefulWidget {
  final Widget title;
  //final Color appBarColor;
  final List<Filter> filters;
  final imageLib.Image image;
  final Widget loader;
  final BoxFit fit;
  final String filename;
  final bool circleShape;

  const FilterPage({
    Key key,
    @required this.title,
    @required this.filters,
    @required this.image,
    //this.appBarColor = Colors.white,
    this.loader = const Center(child: CircularProgressIndicator()),
    this.fit = BoxFit.cover,
    @required this.filename,
    this.circleShape = false,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _FilterPage();
}

class _FilterPage extends State<FilterPage> {
  static final style = TextStyle(
      fontSize: 30,
      fontFamily: "Federika",
      fontWeight: FontWeight.w600,
      color: Colors.white);

  String filename;
  Map<String, List<int>> cachedFilters = {};
  Filter _filter;
  imageLib.Image image;
  bool loading;

  @override
  void initState() {
    super.initState();
    loading = false;
    _filter = widget.filters[0];
    filename = widget.filename;
    image = widget.image;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            'Wizart',
            style: style,
          ),
          textTheme: TextTheme(headline2: style),
          //backgroundColor: Colors.white,
          actions: <Widget>[
            loading
                ? Container()
                : IconButton(
                    icon: Icon(Icons.check),
                    onPressed: () async {
                      setState(() {
                        loading = true;
                      });
                      var imageFile = await saveFilteredImage();

                      Navigator.pop(context, {'image_filtered': imageFile});
                    },
                  )
          ],
        ),
        body: Container(
          child: loading
              ? widget.loader
              : Container(
                  child: Stack(
                    children: <Widget>[
                      TopBar(),
                      BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Stack(
                          alignment: Alignment.centerRight,
                          children: [
                            Center(
                              child: Container(
                                  padding: EdgeInsets.all(15.0),
                                  child: _buildFilteredImage(
                                      _filter, image, filename)),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.3,
                              color: Colors.transparent,
                              alignment: Alignment.bottomRight,
                              child: ListView.builder(
                                scrollDirection: Axis.vertical,
                                itemCount: widget.filters.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return InkWell(
                                    child: Container(
                                      padding: EdgeInsets.all(2.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Container(
                                            decoration: BoxDecoration(
                                                //color: Colors.white,
                                                shape: BoxShape.circle),
                                            padding: EdgeInsets.all(2),
                                            child: _buildFilterThumbnail(
                                                widget.filters[index],
                                                image,
                                                filename),
                                          ),
                                          SizedBox(
                                            height: 5.0,
                                          ),
                                          Text(
                                            widget.filters[index].name,
                                          )
                                        ],
                                      ),
                                    ),
                                    onTap: () => setState(() {
                                      _filter = widget.filters[index];
                                    }),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  _buildFilterThumbnail(Filter filter, imageLib.Image image, String filename) {
    if (cachedFilters[filter?.name ?? "_"] == null) {
      return FutureBuilder<List<int>>(
        future: compute(applyFilter, <String, dynamic>{
          "filter": filter,
          "image": image,
          "filename": filename,
        }),
        builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.active:
            case ConnectionState.waiting:
              return CircleAvatar(
                backgroundColor: Colors.transparent,
                radius: 40.0,
                child: Center(
                  child: widget.loader,
                ),
              );
            case ConnectionState.done:
              if (snapshot.hasError)
                return Center(child: Text('Error: ${snapshot.error}'));
              cachedFilters[filter?.name ?? "_"] = snapshot.data;
              return CircleAvatar(
                backgroundColor: Colors.transparent,
                radius: 30.0,
                backgroundImage: MemoryImage(
                  snapshot.data,
                ),
              );
          }
          return null; // unreachable
        },
      );
    } else {
      return CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 30.0,
        backgroundImage: MemoryImage(
          cachedFilters[filter?.name ?? "_"],
        ),
      );
    }
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/filtered_${_filter?.name ?? "_"}_$filename');
  }

  Future<File> saveFilteredImage() async {
    var imageFile = await _localFile;
    await imageFile.writeAsBytes(cachedFilters[_filter?.name ?? "_"]);
    return imageFile;
  }

  Widget _buildFilteredImage(
      Filter filter, imageLib.Image image, String filename) {
    if (cachedFilters[filter?.name ?? "_"] == null) {
      return FutureBuilder<List<int>>(
        future: compute(applyFilter, <String, dynamic>{
          "filter": filter,
          "image": image,
          "filename": filename,
        }),
        builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return widget.loader;
            case ConnectionState.active:
            case ConnectionState.waiting:
              return widget.loader;
            case ConnectionState.done:
              if (snapshot.hasError)
                return Center(child: Text('Error: ${snapshot.error}'));
              cachedFilters[filter?.name ?? "_"] = snapshot.data;
              return widget.circleShape
                  ? SizedBox(
                      height: MediaQuery.of(context).size.width / 3,
                      width: MediaQuery.of(context).size.width / 3,
                      child: Center(
                        child: CircleAvatar(
                          radius: MediaQuery.of(context).size.width / 3,
                          backgroundImage: MemoryImage(
                            snapshot.data,
                          ),
                        ),
                      ),
                    )
                  : Image.memory(
                      snapshot.data,
                      fit: widget.fit,
                    );
          }
          return null; // unreachable
        },
      );
    } else {
      return widget.circleShape
          ? SizedBox(
              height: MediaQuery.of(context).size.width / 3,
              width: MediaQuery.of(context).size.width / 3,
              child: Center(
                child: CircleAvatar(
                  radius: MediaQuery.of(context).size.width / 3,
                  backgroundImage: MemoryImage(
                    cachedFilters[filter?.name ?? "_"],
                  ),
                ),
              ),
            )
          : Image.memory(
              cachedFilters[filter?.name ?? "_"],
              fit: widget.fit,
            );
    }
  }
}

///The global applyfilter function
List<int> applyFilter(Map<String, dynamic> params) {
  Filter filter = params["filter"];
  imageLib.Image image = params["image"];
  String filename = params["filename"];
  List<int> _bytes = image.getBytes();
  if (filter != null) {
    filter.apply(_bytes, image.width, image.height);
  }
  imageLib.Image _image =
      imageLib.Image.fromBytes(image.width, image.height, _bytes);
  _bytes = imageLib.encodeNamedImage(_image, filename);

  return _bytes;
}

///The global buildThumbnail function
List<int> buildThumbnail(Map<String, dynamic> params) {
  int width = params["width"];
  params["image"] = imageLib.copyResize(params["image"], width: width);
  return applyFilter(params);
}
