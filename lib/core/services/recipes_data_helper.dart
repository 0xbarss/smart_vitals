import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class RecipeDatabaseHelper {
  static final RecipeDatabaseHelper _instance = RecipeDatabaseHelper._internal();
  factory RecipeDatabaseHelper() => _instance;
  RecipeDatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "recipes.db");

    if (!await File(path).exists()) {
      try {
        ByteData data = await rootBundle.load(join("assets", "recipes.db"));
        List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await File(path).writeAsBytes(bytes);
      } catch (e) {
        throw Exception("Error copying database: $e");
      }
    }

    return await openDatabase(path, version: 1);
  }

  Future<List<Map<String, dynamic>>> searchRecipes(String query, {int limit = 1000, int offset = 0}) async {
    final db = await database;

    if (query.isEmpty) {
      return await db.query('recipes', limit: limit, offset: offset);
    }

    String sanitizedQuery = query.replaceAll(RegExp(r'[^a-zA-Z0-9 ]'), '');
    String searchPattern = '$sanitizedQuery*';

    final String sql = '''
      SELECT main.* FROM recipes main
      JOIN recipes_fts fts ON main.id = fts.rowid
      WHERE recipes_fts MATCH ? 
      ORDER BY main.id
      LIMIT ? OFFSET ?
    ''';

    return await db.rawQuery(sql, [searchPattern, limit, offset]);
  }
}