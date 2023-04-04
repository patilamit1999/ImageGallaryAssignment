import 'package:sqflite/sqflite.dart';

class ImageData {
  int? id;
  String path;
  String title;

  ImageData({
    required this.id,
    required this.path,
    required this.title,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'path': path,
      'title': title,
    };
  }
}

