import 'dart:async';

import 'package:flare_splash_screen/flare_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wizart/ui/wizart.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(new MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wizart',
      theme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      home: WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  var _style = TextStyle(
      fontSize: 40,
      fontFamily: "Billy",
      fontWeight: FontWeight.w500,
      color: Colors.white);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var _size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          SplashScreen.callback(
            name: "assets/loader.flr",
            onSuccess: (_) {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => WizartPage(),
              ));
            },
            onError: (e, s) {},
            height: _size.height,
            startAnimation: '0',
            endAnimation: '4',
            loopAnimation: 'Untitled',
            //backgroundColor: Colors.white,
            until: () => Future.delayed(Duration(milliseconds: 4)),
          ),
          Center(
              child: Container(
            padding: EdgeInsets.only(top: _size.height * 0.1),
            child: Text(
              'WizArT',
              style: _style,
            ),
          )),
        ],
      ),
    );
  }
}
