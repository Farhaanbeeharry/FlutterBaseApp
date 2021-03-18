import 'dart:async';
import 'dart:io';

import 'package:driver/Common/Classes/ApiUrl.dart';
import 'package:driver/Common/Models/keyValueModel.dart';
import 'package:flutter_guid/flutter_guid.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();
  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;

    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "Naveo.db");
    return await openDatabase(
      path,
      version: 1,
    );
  }

  initialiseDB() async {
    final db = await database;
    await db.execute("CREATE TABLE IF NOT EXISTS KeyValue ("
        "id TEXT PRIMARY KEY,"
        "key TEXT,"
        "value TEXT"
        ")");
    await _initialiseClockDB(db);
    await addIfNotExist("DeviceAssigned", "false");
    await addIfNotExist("CompanyToken", "hA2.*c9x6a2PgaZMi_6Sg328@1pc35p9");
    await addIfNotExist("ChosenServer", "Kids");
    await addIfNotExist("EmailAddress", "null");
    await addIfNotExist("Password", "null");
    await addIfNotExist("OneTimeToken", "null");
    await addIfNotExist("UserToken", "null");
    await addIfNotExist("clockStatus", "0");
    await addIfNotExist("clockInitialStartTime", "0");
    await addIfNotExist("clockInitialEndTime", "0");
    await addIfNotExist("clockStartTime", "0");
    await addIfNotExist("clockEndTime", "0");
    await ApiUrl.setURL();
  }

  _initialiseClockDB(Database db) async {
    await db.execute("CREATE TABLE IF NOT EXISTS clock ("
        "id INTEGER PRIMARY KEY,"
        "initialStartTime VARCHAR(255),"
        "initialEndTime VARCHAR(255),"
        "startTime VARCHAR(255),"
        "endTime VARCHAR(255)"
        ")");
  }

  addIfNotExist(String key, String value) async {
    if (await checkExistingKey(key) == false) {
      KeyValue newKeyValue = new KeyValue();
      newKeyValue.key = key;
      newKeyValue.value = value;
      addNewKeyValue(newKeyValue);
    }
  }

  addNewKeyValue(KeyValue newKeyValue) async {
    final db = await database;
    var res = await db.rawInsert("INSERT Into KeyValue (id, key, value)"
        " VALUES ('${Guid.newGuid}','${newKeyValue.key}', '${newKeyValue.value}')");
    return res;
  }

  Future<String> getValueByKey(String key) async {
    final db = await database;
    var res = await db.query("KeyValue WHERE key = '$key'");
    List<KeyValue> list =
        res.isNotEmpty ? res.map((c) => KeyValue.fromMap(c)).toList() : [];
    return list[0].value;
  }

  checkDatabase() async {
    final db = await database;
    var res = await db.query("KeyValue");
    List<KeyValue> list =
        res.isNotEmpty ? res.map((c) => KeyValue.fromMap(c)).toList() : [];
    for (int i = 0; i < list.length; i++) {
      print("TEST - " + list[i].key + " - " + list[i].value);
    }
  }

  setPinCode(String pinCode) {
    KeyValue pinCodeKeyValue = new KeyValue();
    pinCodeKeyValue.key = "PinCode";
    pinCodeKeyValue.value = pinCode;

    DBProvider.db.addNewKeyValue(pinCodeKeyValue);
  }

  dropDatabase() async {
    final db = await database;
    await db.execute("DROP TABLE KeyValue");
  }

  Future<bool> checkExistingKey(String key) async {
    final db = await database;
    var res = await db.query("KeyValue WHERE key = '$key'");
    List<KeyValue> list =
        res.isNotEmpty ? res.map((c) => KeyValue.fromMap(c)).toList() : [];
    if (list.length > 0) {
      return true;
    } else
      return false;
  }

  updateValueByKey(String key, String value) async {
    final db = await database;
    await db.execute("UPDATE KeyValue SET value = '$value' WHERE key = '$key'");
  }
}
