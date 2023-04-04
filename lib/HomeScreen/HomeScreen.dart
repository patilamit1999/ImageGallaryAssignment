import 'dart:io';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../model/image_model.dart';
import '../services/auth_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PlatformFile? _selectedFile;
  double _uploadedPercentage = 0;

  Future<void> _selectFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      uploadExampleData(result.files.first);
    }
  }

  Future<void> uploadExampleData(PlatformFile file) async {

    try {
      setState(() {
        _selectedFile = file;
      });

      final data = File(file.path!);
      final bytes = await data.readAsBytes();
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
      final path = '${appDir.path}/$fileName';
      await File(path).writeAsBytes(bytes);

      final imageData = ImageData(
        id: null,
        path: path,
        title: file.name,
      );

      final id = await DBHelper.insertImage(imageData);
      imageData.id = id;

      final result = await Amplify.Storage.uploadFile(
        localFile: AWSFile.fromPath(
          file.path!,
        ),
        key: file.name,
        onProgress: (progress) {
          setState(() {
            _uploadedPercentage = progress.fractionCompleted;
          });
        },
      ).result;

      safePrint('Uploaded data to location: ${result.uploadedItem.key}');
      _deselectFile();
    } on StorageException catch (e) {
      safePrint(e.message);
    }
  }

  void _deselectFile() {
    setState(() {
      _selectedFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isFileSelected = _selectedFile != null;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isFileSelected
                ? 'You selected a file at path ${_selectedFile?.path}'
                : 'Click the button below to select a file.',
          ),
          if (isFileSelected)
            CircularProgressIndicator(
              value: _uploadedPercentage,
            ),
          ElevatedButton(
            onPressed: isFileSelected ? _deselectFile : _selectFile,
            child: Text(isFileSelected ? 'Deselect File' : 'Select File'),
          )
        ],
      ),
    );
  }
}