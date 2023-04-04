
import 'package:path_provider/path_provider.dart';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'dart:io' as io;

import '../model/image_model.dart';
import '../model/user_model.dart';

class DBHelper {
  static Database? _db;

  Future<Database?> get db async {
    if (_db != null) {
      return _db!;
    }

    _db = await initDatabase();
    return _db;
  }

  initDatabase() async {
    io.Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, 'auth.db');
    var db = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
    return db;
  }

  _onCreate(Database db, int version) async {
    await db.execute(
      'CREATE TABLE Auth (email VARCHAR UNIQUE, password VARCHAR)',
    );
    await db.execute(
        """ CREATE TABLE images(id INTEGER PRIMARY KEY, path TEXT, title TEXT)"""
    );
  }

  static Future<int> insertImage(ImageData imageData) async {
    final db = _db;

    return await db!.insert(
      'images',
      imageData.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ImageData>> getAllImages() async {
    final List<Map<String, dynamic>> maps = await _db!.query('images');

    return List.generate(maps.length, (i) {
      return ImageData(
        id: maps[i]['id'],
        path: maps[i]['path'],
        title: maps[i]['title'],
      );
    });
  }

  Future<User> insert(User user) async {
    var dbClient = await db;
    try {
      await dbClient!.insert('auth', user.toMap());
    } catch (error) {
      print(error);
    }
    return user;
  }

   Future<int> deleteImage(int id) async {
    return await _db!.delete(
      'images',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  Future<bool> isUserExist(String email, String password) async {
    var dbClient = await db;
    final List<Map<String, Object?>> queryResult =
        await dbClient!.query('auth');
    var allUsers = queryResult.map((e) => User.fromMap(e)).toList();
    for(var userInfo in allUsers){
      print("Hello *******************");
      print("Password :${userInfo.password}");
      if( password == userInfo.password){
        return true;
      }
    }
    return false;
  }

  Future<bool> isUserAlreadyExist() async {
    var dbClient = await db;
    final List<Map<String, Object?>> queryResult =
    await dbClient!.query('auth');
    var allUsers = queryResult.map((e) => User.fromMap(e)).toList();
    if(allUsers.isNotEmpty){
      return true;
    }
    return false;
  }
}
