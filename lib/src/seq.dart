// File: lib/src/seq.dart
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
      if (minValue != null) {
        db.execute(
            'INSERT INTO $TABLE_NAME (name, last_value) VALUES (?, ?)',
            [name, minValue - 1]
        );
      } else {
        throw StateError('Could not initialize sequence: invalid minimum value');
      }
    }
  }

  int? _getMinSequenceValue() {
    final seqStartValue = Bootstrap.apiConfig['bX']['seqStartValue'] as String;
    final conversion = B10.convertBxToB10(seqStartValue);

    // Handle potential invalid start value
    if (conversion.isEmpty || conversion[0].isEmpty) {
      return null;
    }
    return conversion[0][0];
  }

  String? nextValue({String? prepend, bool useDefaultPrepend = false}) {
    final minValue = _getMinSequenceValue();
    if (minValue == null) {
      return null;  // Return null if we can't establish a valid minimum value
    }

    try {
      final result = db.select(
          'UPDATE $TABLE_NAME SET last_value = last_value + 1 WHERE name = ? RETURNING last_value',
          [name]
      );

      if (result.isEmpty) {
        return null;
      }

      final b10Value = result.first['last_value'] as int;
      return B10.convertB10ToBx(b10Value, prepend: prepend, useDefaultPrepend: useDefaultPrepend);
    } catch (e) {
      return null;  // Return null on any database errors
    }
  }

  int? getCurrentValue() {
    try {
      final result = db.select(
          'SELECT last_value FROM $TABLE_NAME WHERE name = ?',
          [name]
      );

      if (result.isEmpty) {
        final minValue = _getMinSequenceValue();
        return minValue != null ? minValue - 1 : null;
      }

      return result.first['last_value'] as int;
    } catch (e) {
      return null;  // Return null on any database errors
    }
  }

  bool reset() {
    final minValue = _getMinSequenceValue();
    if (minValue == null) {
      return false;
    }

    try {
      db.execute(
          'UPDATE $TABLE_NAME SET last_value = ? WHERE name = ?',
          [minValue - 1, name]
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    db.dispose();
  }

  // New helper methods for validation
  bool isValidSequence() {
    return _getMinSequenceValue() != null;
  }

  static bool isValidSequenceValue(String value) {
    final conversion = B10.convertBxToB10(value);
    return conversion.isNotEmpty && conversion[0].isNotEmpty;
  }
}