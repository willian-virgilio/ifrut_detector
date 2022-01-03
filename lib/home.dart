import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final picker = ImagePicker();
  late File _image;
  bool _loading = false;
  List _output = [''];

  pickImage() async {
    var image = await picker.getImage(source: ImageSource.camera);

    if (image == null) return null;
    setState(() {
      _image = File(image.path);
    });
    classifyImage(_image);
  }

  pickGallaryImage() async {
    var image = await picker.getImage(source: ImageSource.gallery);

    if (image == null) return null;
    setState(() {
      _image = File(image.path);
    });
    classifyImage(_image);
  }

  @override
  void initState() {
    super.initState();
    _loading = true;
    loadModel().then((value) {});
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 5,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );

    setState(() {
      _loading = false;
      if (output != null) {
        _output = (output).toList();
      }
    });
  }

  loadModel() async {
    await Tflite.loadModel(
        model: 'assets/model.tflite', labels: 'assets/labels.txt');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.004, 1],
            colors: [
              Color(0xFFa8e063),
              Color(0xFF56ab2f),
            ],
          ),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 50,
              ),
              Text(
                "Detect  Flowers",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 28),
              ),
              Text(
                "Custon TensotFlow CNN",
                style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
              SizedBox(height: 40),
              Container(
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.amberAccent,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7),
                  ],
                ),
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Center(
                        child: _loading
                            ? Container(
                                width: 300,
                                child: Column(
                                  children: <Widget>[
                                    Image.asset(
                                      'assets/flower.png',
                                    ),
                                    SizedBox(
                                      height: 40,
                                    )
                                  ],
                                ),
                              )
                            : Container(
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      height: 300,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.file(_image),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    _output != null
                                        ? Text(
                                            'Prediction is: ${_output[0]['label']}',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 20),
                                          )
                                        : Container(),
                                    SizedBox(
                                      height: 20,
                                    )
                                  ],
                                ),
                              ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        children: <Widget>[
                          GestureDetector(
                            onTap: pickImage,
                            child: Container(
                              width: MediaQuery.of(context).size.width - 180,
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 17),
                              decoration: BoxDecoration(
                                  color: Color(0xFF56ab2f),
                                  borderRadius: BorderRadius.circular(6)),
                              child: Text(
                                'Take a photo of the flower',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          GestureDetector(
                            onTap: pickImage,
                            child: Container(
                              width: MediaQuery.of(context).size.width - 180,
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 17),
                              decoration: BoxDecoration(
                                  color: Color(0xFF56ab2f),
                                  borderRadius: BorderRadius.circular(6)),
                              child: Text(
                                'Camera Roll',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
