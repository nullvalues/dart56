import 'package:sqlite3/sqlite3.dart';
import '../config_api.dart';
import 'b10.dart';

class BxSequence {
  final String name;
  final Database db;
  static const String TABLE_NAME = 'bx_sequences';

  BxSequence(this.name) : db = _initDatabase() {
    _initializeIfNeeded();
  }

  static Database _initDatabase() {
    final db = sqlite3.open('sequences.db');
    db.execute('''
      CREATE TABLE IF NOT EXISTS $TABLE_NAME (
        name TEXT PRIMARY KEY,
        last_value INTEGER NOT NULL DEFAULT 0
      )
    ''');
    return db;
  }

  void _initializeIfNeeded() {
    final existing = db.select(
        'SELECT last_value FROM $TABLE_NAME WHERE name = ?',
        [name]
    );

    if (existing.isEmpty) {
      final minValue = _getMinSequenceValue();
      db.execute(
          'INSERT INTO $TABLE_NAME (name, last_value) VALUES (?, ?)',
          [name, minValue - 1]
      );
    }
  }

  int _getMinSequenceValue() {
    final seqStartValue = Bootstrap.apiConfig['bX']['seqStartValue'] as String;
    return B10.convertBxToB10(seqStartValue);
  }

  String nextValue({String? prepend, bool useDefaultPrepend = false}) {
    final result = db.select(
        'UPDATE $TABLE_NAME SET last_value = last_value + 1 WHERE name = ? RETURNING last_value',
        [name]
    );

    final b10Value = result.first['last_value'] as int;
    return B10.convertB10ToBx(b10Value, prepend: prepend, useDefaultPrepend: useDefaultPrepend);
  }

  int getCurrentValue() {
    final result = db.select(
        'SELECT last_value FROM $TABLE_NAME WHERE name = ?',
        [name]
    );
    return result.isNotEmpty ? result.first['last_value'] as int : _getMinSequenceValue() - 1;
  }

  void reset() {
    final minValue = _getMinSequenceValue() - 1;
    db.execute(
        'UPDATE $TABLE_NAME SET last_value = ? WHERE name = ?',
        [minValue, name]
    );
  }

  void dispose() {
    db.dispose();
  }
}