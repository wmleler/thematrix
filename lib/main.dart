import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:ui' show lerpDouble;

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Flutter 3D Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {

  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {

  double rotation = 0.0;
  int counter = 0;

  AnimationController animation;
  String axis = 'Y';

  @override
  void initState() {
    super.initState();
    animation = new AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    )
      ..addListener(() {
        setState(() {
          rotation = -Curves.easeOut.transform(animation.value)*8*PI;
        });
      });
    rotation = 0.0;
  }

  void _spinZ(DragEndDetails details) {
    axis = 'Z';
    animation.forward(from: 0.0);
  }

  void _spinY(DragEndDetails details) {
    axis = 'Y';
    animation.forward(from: 0.0);
  }

  void _spinX(DragEndDetails details) {
    axis = 'X';
    animation.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return new Transform(
      transform: axis == 'X' ? new Matrix4.rotationX(rotation/4) :
          (axis == 'Y' ? new Matrix4.rotationY(rotation/4) :
          new Matrix4.rotationZ(rotation/4)),
      alignment: FractionalOffset.center,
      child: new Scaffold(
        appBar: new AppBar(
          title: new Text(widget.title),
        ),
        floatingActionButton: new FloatingActionButton(
          onPressed: () => setState(()=>counter++),
          tooltip: 'Increment',
          child: new Icon(Icons.add),
        ),
        body: new Builder(builder: (BuildContext ctx)=>new GestureDetector(
            onVerticalDragEnd: _spinZ,
            onHorizontalDragEnd: _spinY,
            child: new Transform(
              transform: new Matrix4.rotationZ(rotation),
              alignment: FractionalOffset.center,
              child: new Center(
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Text("Count = $counter"),
                      new RaisedButton(
                        child: new Text("Widget Spinner"),
                        color: Colors.yellow,
                        onPressed: () => setState(()=>counter++),
                      ),
                    ],
                  )),
            ))),
      ));
  }

}
