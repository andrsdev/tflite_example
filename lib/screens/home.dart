import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_example/components/picture_picker.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final ImagePicker _imagePicker = ImagePicker();
  File _selectedPicture;

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
        // validateImageFile(croppedImage);
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
              padding: const EdgeInsets.only(top: 36.0),
              child: PicturePicker(
                imageFile: _selectedPicture,
                shape: BoxShape.rectangle,
                width: MediaQuery.of(context).size.width - 64,
                onTap: () => pickImage(ImageSource.gallery)
              ),
            )
          ],
        ),
      ),
    );
  }
}
