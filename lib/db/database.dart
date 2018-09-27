import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DBManager {
  DBManager._internal();

  static DBManager _shared = DBManager._internal();
  static DBManager shared() {
    return _shared;
  }

  Database db;

  Future init({String name = 'test.db', int version = 1}) async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, name);
    if (version != 1) {
      await deleteDatabase(path);
    }
    var db = await openDatabase(path, version: version, onCreate: _create);
    print('DB INITIATED WITH PATH : $path');
    this.db = db;
    return db;
  }

  Future _create(Database db, int version) async {
    await db.transaction((txn) async {
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS test_table (
          id TEXT PRIMARY KEY,
          data_uint BLOB NOT NULL,
          data_utf BLOB NOT NULL
      );
      ''');
    });
  }

  Future closeDB() async {
    await db.close();
  }

  Future<bool> saveData() async {
    final id = Uuid().v1();
    final dataUtf = utf8.encode(id);
    print('$id - $dataUtf');

    try {
      print('$id - $dataUtf');
      final _ = await db.rawQuery('''
        INSERT OR REPLACE INTO test_table
        (id, data_uint, data_utf) VALUES (?, ?, ?)''', [id, dataUtf, dataUtf]);
      print(' DATA SAVED');
      return true;
    } catch (e) {
      print('FAILED SAVING DATA: ${e.toString()}');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchData() async {
    try {
      final res = db.rawQuery('SELECT * FROM test_table');
      return res;
    } catch (e) {
      print('FAILED FETCH DATA: ${e.toString()}');
      return [];
    }
  }
}
