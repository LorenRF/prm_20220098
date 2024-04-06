import 'package:sqflite/sqflite.dart';

class DataBaseHelper {
  static DataBaseHelper? _baseHelper;

  DataBaseHelper._internal();

  static DataBaseHelper get instance => _baseHelper ??= DataBaseHelper._internal();

  Database? _db;
  Database get db => _db!;

  Future<void> init() async {
    _db = await openDatabase('database.db', version: 1, onCreate: (db, version) {
      db.execute('CREATE TABLE Eventos (id INTEGER PRIMARY KEY AUTOINCREMENT, userid INTEGER, title VARCHAR(40), description VARCHAR(350), date VARCHAR(30), imagePath VARCHAR(140), audioPath VARCHAR(140))');
      db.execute('CREATE TABLE Usuarios (id INTEGER PRIMARY KEY AUTOINCREMENT, photoUrl VARCHAR(140), firstName VARCHAR(20), lastName VARCHAR(30), matricula VARCHAR(8), password VARCHAR(40))');
    });
  }
}
