import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'package:tflite_example/components/picture_picker.dart';
import 'package:tflite_example/models/result.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final ImagePicker _imagePicker = ImagePicker();
  File _selectedPicture;
  Result _result;

  void pickImage(ImageSource source) async {
    PickedFile picked = await _imagePicker.getImage(source: source);
    if(picked != null) {
      File image = File(picked.path);
      cropImage(image);
    }
  }

  void cropImage(File image) async {
    File croppedImage = await ImageCropper.cropImage(
      cropStyle: CropStyle.rectangle,
      sourcePath: image.path,
      aspectRatio: CropAspectRatio(
        ratioX: 3,
        ratioY: 2
      ),
      maxWidth: 512,
      maxHeight: 512,
    );

    if(croppedImage != null && this.mounted){
      setState(() {
        this._selectedPicture = croppedImage;
        identifyImage(croppedImage);
      });
    }
  }

  Future<void> identifyImage(File file) async {
    await Tflite.loadModel(
      model: "assets/tflite/model.tflite",
      labels: "assets/tflite/labels.txt",
      numThreads: 1
    );

    List<dynamic> recognitions = await Tflite.runModelOnImage(
      path: file.path,
      numResults: 1,
      imageMean: 128,
      imageStd: 128,
    );

    if(recognitions.isNotEmpty){
      dynamic recognition = recognitions.first;
      _result = Result(confidence: recognition['confidence']);

      setState(() {
        switch (recognition['index']) {
          case 0: _result.name = 'Pikachu'; break;
          case 1: _result.name = 'Squirtle'; break;
          case 2: _result.name = 'Unidentified'; break;
        }
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              "Pokédex",
              style: Theme.of(context).textTheme.headline4.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w700
              ),
              textAlign: TextAlign.start,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 18.0),
              child: Text(
                "Select a picture to indentify the pókemon!",
                textAlign: TextAlign.start,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 36.0),
              child: PicturePicker(
                imageFile: _selectedPicture,
                shape: BoxShape.rectangle,
                width: MediaQuery.of(context).size.width - 56,
                onTap: () => pickImage(ImageSource.gallery)
              ),
            ),

            if(_result != null)
            Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 28.0, bottom: 24),
                  child: Divider(),
                ),
                Text(
                  _result.name,
                  style: Theme.of(context).textTheme.headline5,
                ),
                Text(
                  '${(_result.confidence * 100).toStringAsFixed(2)} %',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                  
              ],
            )
          ],
        ),
      ),
    );
  }
}
