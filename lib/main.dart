import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
// import 'dart:ui' show lerpDouble;

void main() {
  runApp(new MyApp());
}

const int MAX_ABS_PERSPECTIVE = 20;

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
  int counter;
  Matrix4 perspective;

  AnimationController animation;
  double scale = 1.0;
  Offset startPoint;

  ImmediateMultiDragGestureRecognizer _recognizer;

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
    rotX = 0.0;
    rotY = 0.0;
    rotZ = 0.0;
    counter = 10;
    perspective = _pmat(counter);
    _recognizer = new ImmediateMultiDragGestureRecognizer()..onStart = onStart;
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
      0.0, 0.0, 1.0, pv * 0.0001, //
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
      if (details.pointers.keys.length == 1) {
        // tilt (pan)
        // TODO: perform tilt based on details.focalPoint - startPoint
        Offset p = details.focalPoint - startPoint;
        rotX = p.dy * 0.015;
        rotY = -p.dx * 0.015;
//        print('rotX: $rotX rotY: $rotY');
//        print('pan: ${details.focalPoint - startPoint}');
      } else {
        // scale or rotate
//        print('scale/rotate: $details');
        scale = details.scale / scale;
      }
    });
  }

  _scaleEnd(ScaleEndDetails details) {
//    print('end: $details'); // velocity
  }

  onStart(Offset offset) {
    return new MyDrag(this);
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
//            onVerticalDragEnd: _spinX,
//            onHorizontalDragEnd: _spinY,
//            onPanUpdate: _panUpdate,
              onScaleStart: _scaleStart,
              onScaleUpdate: _scaleUpdate,
              onScaleEnd: _scaleEnd,
              child: new Center(
                  child: new Scaffold(
                      appBar: new AppBar(
                        title: new Text(widget.title),
                      ),
                      floatingActionButton: new FloatingActionButton(
                        onPressed: _spinZ,
                        tooltip: 'Spin',
                        child: new Icon(Icons.replay),
                      ),
                      body: new Center(
                        child: new Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new FloatingActionButton(
                              onPressed: () => setState(() {
                                    if (counter < MAX_ABS_PERSPECTIVE) {
                                      perspective = _pmat(++counter);
                                    }
                                  }),
                              mini: true,
                              tooltip: 'Increment',
                              child: new Icon(Icons.arrow_upward),
                            ),
                            new Text(' '),
                            new Text("Perspective: $counter",
                                style: DefaultTextStyle.of(context).style.apply(
                                    fontSizeFactor:
                                        0.6 + (counter.abs() * .01))),
                            new Text(' '),
                            new FloatingActionButton(
                              onPressed: () => setState(() {
                                    if (counter > -MAX_ABS_PERSPECTIVE) {
                                      perspective = _pmat(--counter);
                                    }
                                  }),
                              mini: true,
                              tooltip: 'Decrement',
                              child: new Icon(Icons.arrow_downward),
                            ),
                          ],
                        ),
                      )
                  )
              )
//          ), // Listener
        )
    );
  }

  void _routePointer(PointerEvent event) {
    _recognizer.addPointer(event);
  }
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
