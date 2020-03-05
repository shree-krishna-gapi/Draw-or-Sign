import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_signature_pad/flutter_signature_pad.dart';
import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:image_picker_saver/image_picker_saver.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: Sign(),
    );
  }
}
class Sign extends StatefulWidget {
  @override
  _SignState createState() => new _SignState();
}
class _SignState extends State<Sign> {
  File pickedImage;
  List<Offset> points = <Offset>[];
  final _sign = GlobalKey<SignatureState>();
  static GlobalKey screen = new GlobalKey();
  Future getSign() async {
    RenderRepaintBoundary boundary = _sign.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage();

    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    var filePath = await ImagePickerSaver.saveFile(
        fileData:byteData.buffer.asUint8List() );
    print(filePath);
    _showDialog(filePath);
//    Navigator.of(context).pop(true);

  }
  gallery() {
    pickedImage.openWrite();
  }

  @override
  void _showDialog(imgPath) {
    // flutter defined function
    showDialog(
        context: context,
        builder: (BuildContext context) {
      // return object of type Dialog
      return AlertDialog(
          title: Row(
            children: <Widget>[
              Container(width: 5, height: 22, color: Colors.green[400],),
              SizedBox(width: 15,),
              Expanded(child: Text('Image Save Succefully!'))
            ],
          ),
          elevation: 4,
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
          content: Text('$imgPath'));});
  }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Column(
        children: <Widget>[
          Expanded( flex:4,
            child: RepaintBoundary(
                key: _sign,
                child:Container(
                  key:screen,
                  color: Colors.black12,
                  child: GestureDetector(
                    onPanUpdate: (DragUpdateDetails details) {
                      setState(() {
                        RenderBox object = context.findRenderObject();
                        Offset _localPosition =
                        object.globalToLocal(details.globalPosition);
                        points = new List.from(points)..add(_localPosition);
                      });
                    },
                    onPanEnd: (DragEndDetails details) => points.add(null),
                    child: new CustomPaint(
                      painter: new Signature(points: points),
                      size: Size.infinite,
                    ),
                  ),
                )
            ),
          ),
          Expanded( flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  RaisedButton(onPressed: (){getSign();},
                    splashColor: Colors.amber,
                    child: Text('Save',style: TextStyle(color: Colors.white),),
                    color: Colors.blue,
                  ),

                  RaisedButton( onPressed: () {setState(() {
                    points.clear();
                  });},
                    splashColor: Colors.amber,
                    child: Text('Clear',style: TextStyle(color: Colors.white),),
                    color: Colors.blue[400],
                  ),
                ],
              )
          ),

        ],
      ),
    );
  }
}
class Signature extends CustomPainter {
  List<Offset> points;
  Signature({this.points});
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..color = Colors.blue
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }
  @override
  bool shouldRepaint(Signature oldDelegate) => oldDelegate.points != points;
}