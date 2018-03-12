import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
// import 'dart:ui' show lerpDouble;
import 'package:sensors/sensors.dart';

void main() {
  runApp(new MyApp());
}

const int MAX_ABS_PERSPECTIVE = 2;

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'The Matrix 3D',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'The Matrix 3D'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  double rotX;
  double rotY;
  double rotZ;
  double saveX;
  double saveY;
  double baseX;
  double baseY;
  int counter;
  Matrix4 perspective;
  double scale;
  bool level;
  Color levelColor;
  TextStyle buttonStyle;
  dynamic accelSubscription;

  AnimationController animation;
  Offset startPoint;

//  ImmediateMultiDragGestureRecognizer _recognizer;

  setMyTransform(Offset originOffset, DragUpdateDetails details) {
    setState(() {
      double x = originOffset.dx - details.globalPosition.dx;
      double y = originOffset.dy - details.globalPosition.dy;
      perspective
        ..rotateX(x * 0.001)
        ..rotateY(y * 0.001);

      //      AnimationController ac = new AnimationController(duration: 100)
      //      Curves.easeOut.transform();
    });
  }

  @override
  void initState() {
    super.initState();
    animation = new AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    )..addListener(() {
        setState(() {
          rotZ = -Curves.easeOut.transform(animation.value) * 8 * PI;
        });
      });
    level = false;
    levelColor = Colors.blue;
    buttonStyle = new TextStyle(color: Colors.white, fontSize: 20.0);
    counter = 1;
    _reset3D();
//    _recognizer = new ImmediateMultiDragGestureRecognizer()..onStart = onStart;
  }

  // reset rotations, perspective, and scale to initial values
  void _reset3D() {
    setState(() {
      rotX = 0.0;
      rotY = 0.0;
      rotZ = 0.0;
      baseX = 0.0;
      baseY = 0.0;
      perspective = _pmat(counter);
      scale = 1.0;
    });
  }

  void _spinZ() {
    animation.forward(from: 0.0);
  }

//  void _spinY(DragEndDetails details) {
//    // print('details: ${details.velocity.pixelsPerSecond.dx}');
//    axis = 'Y';
//    animation.forward(from: 0.0);
//  }
//
//  void _spinX(DragEndDetails details) {
//    axis = 'X';
//    animation.forward(from: 0.0);
//  }

  // http://web.iitd.ac.in/~hegde/cad/lecture/L9_persproj.pdf
  // create perspective matrix
  static Matrix4 _pmat(num pv) {
    return new Matrix4(
      1.0, 0.0, 0.0, 0.0, //
      0.0, 1.0, 0.0, 0.0, //
      0.0, 0.0, 1.0, pv * 0.001, //
      0.0, 0.0, 0.0, 1.0,
    );
  }

  _scaleStart(ScaleStartDetails details) {
//    print('scale_start: $details');
    // save point where finger went down
    startPoint = details.focalPoint;
  }

  _scaleUpdate(ScaleUpdateDetails details) {
//    print('$details');
    setState(() {
      if (details.scale == 1.0) {  // tilt (pan)
        Offset p = details.focalPoint - startPoint;
        saveX = 0.015 * p.dy;
        rotX = baseX + saveX;
        saveY = -0.015 * p.dx;
        rotY = baseY + saveY;
//        print('X tilt: $rotX Y tilt: $rotY');
//        print('pan: ${details.focalPoint - startPoint}');
      } else {
        // scale (or rotate)œ
//        print('scale/rotate: $details');
        scale = details.scale / scale;
      }
    });
  }

  _scaleEnd(ScaleEndDetails details) {
//    print('end: $details'); // velocity
    baseX = saveX;
    baseY = saveY;
  }

  // change to LEVEL mode and back
  _changeMode() {
//    print('changemode');
    if (level) {
      level = false;
      setState(() {
        levelColor = Colors.blue;
      });
      accelSubscription.cancel(); // turn off accelerometer
    } else {
      level = true;
      levelColor = Colors.green;
      // https://www.digikey.com/en/articles/techzone/2011/may/using-an-accelerometer-for-inclination-sensing
      // https://pub.dartlang.org/packages/sensors
      // convert x, y, z acceleration into tilts for X and Y axis
      // Phone laying flat should give 0, 0
      accelSubscription = accelerometerEvents.listen((AccelerometerEvent ae) {
        // Do something with the event.
        double x2 = ae.x * ae.x;
        double y2 = ae.y * ae.y;
        double z2 = ae.z * ae.z;
        setState(() {
          rotX = -atan(ae.y / sqrt(x2 + z2));
          rotY = -atan(ae.x / sqrt(y2 + z2));
//          print('X tilt: $rotX Y tilt: $rotY');
        });
      });
      _reset3D();
    }
  }

  onStart(Offset offset) {
    return new MyDrag(this);
  }

  changeLevel(bool value) {
//    print("level: $value");
    level = value;
  }

  @override
  Widget build(BuildContext context) {
    return new Transform(
        transform: perspective.scaled(scale, scale, 1.0)
          ..rotateX(rotX)
          ..rotateY(rotY)
          ..rotateZ(rotZ / 4),
        alignment: FractionalOffset.center,
//        child: new Listener(
//          onPointerDown: _routePointer,
        child: new GestureDetector(
            onLongPress: _reset3D,
//            onVerticalDragEnd: _spinX,
//            onHorizontalDragEnd: _spinY,
//            onPanUpdate: _panUpdate,
            onScaleStart: _scaleStart,
            onScaleUpdate: _scaleUpdate,
            onScaleEnd: _scaleEnd,
            child: new Scaffold(
              appBar: new AppBar(
                title: new Text(widget.title),
              ),
//                      floatingActionButton: new FloatingActionButton(
//                        onPressed: _spinZ,
//                        tooltip: 'Spin',
//                        child: new Icon(Icons.replay),
//                      ),
              body: new Center(
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Text(' '),
                    new FloatingActionButton(
                      onPressed: () => setState(() {
                            if (counter < MAX_ABS_PERSPECTIVE) {
                              perspective = _pmat(++counter);
                            }
                          }),
                      tooltip: 'Increment',
                      child: new Icon(Icons.arrow_upward),
                    ),
                    new Text(' '),
                    new Text("Perspective: $counter",
                        style: DefaultTextStyle.of(context).style.apply(
                            fontSizeFactor: 0.6 + (counter.abs() * .01))),
                    new Text(' '),
                    new FloatingActionButton(
                      onPressed: () => setState(() {
                            if (counter > -MAX_ABS_PERSPECTIVE) {
                              perspective = _pmat(--counter);
                            }
                          }),
                      tooltip: 'Decrement',
                      child: new Icon(Icons.arrow_downward),
                    ),
                    new Text('\n'),
                  ],
                ),
              ),
              persistentFooterButtons: <Widget>[
                new RaisedButton(
                  color: Colors.blue,
                  onPressed: _spinZ,
                  child: new Text("SPIN", style: buttonStyle),
                ),
                new Padding(
                  padding: new EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 15.0),
                  child: new RaisedButton(
                    color: levelColor,
                    onPressed: _changeMode,
                    child: new Text("LEVEL", style: buttonStyle),
                  ),
                ),
                new RaisedButton(
                  color: Colors.blue,
                  onPressed: _reset3D,
                  child: new Text("RESET", style: buttonStyle),
                ),
              ],
            )
//          ), // Listener
            ));
  }

//  void _routePointer(PointerEvent event) {
//    _recognizer.addPointer(event);
//  }
}

class MyDrag extends Drag {
  _MyHomePageState state;
  bool start = false;
  Offset originOffset;
  MyDrag(this.state) {
    start = true;
  }

  void update(DragUpdateDetails details) {
    if (start) {
      originOffset = details.globalPosition;
      start = false;
    }
    state.setMyTransform(originOffset, details);
  }
}
