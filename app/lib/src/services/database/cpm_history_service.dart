import 'package:talk_pilot/src/models/cpm_record_model.dart';
import 'package:talk_pilot/src/services/database/database_service.dart';
import 'package:talk_pilot/src/services/database/user_service.dart';

extension CpmHistoryService on UserService {
  DatabaseService get _cpmDb => DatabaseService();

  Future<void> addCpmRecord(
    String uid,
    CpmRecordModel record, {
    DatabaseService? db,
  }) async {
    final recordId = record.timestamp.millisecondsSinceEpoch.toString();
    final targetDb = db ?? _cpmDb;
    await targetDb.writeDB("users/$uid/cpmHistory/$recordId", record.toMap());
  }

  Future<List<CpmRecordModel>> getCpmHistory(
    String uid, {
    DatabaseService? db,
  }) async {
    final _db = db ?? _cpmDb;
    return _db.fetchDB<CpmRecordModel>(
      path: "users/$uid/cpmHistory",
      fromMap: (map) => CpmRecordModel.fromMap(map),
    );
  }

  Future<void> updateAverageCpm(String uid, {DatabaseService? db}) async {
    final history = await getCpmHistory(uid, db: db);
    if (history.isEmpty) return;

    final avg =
        history.map((e) => e.cpm).reduce((a, b) => a + b) / history.length;
    await updateUser(uid, {'cpm': avg});
  }

  Future<void> clearCpmHistory(String uid, {DatabaseService? db}) async {
    final _db = db ?? _cpmDb;
    await _db.deleteDB("users/$uid/cpmHistory");
    await updateUser(uid, {'cpm': 0.0});
  }

  Future<void> deleteCpmRecord(
    String uid,
    int timestampMillis, {
    DatabaseService? db,
  }) async {
    final _db = db ?? _cpmDb;
    final recordId = timestampMillis.toString();
    await _db.deleteDB("users/$uid/cpmHistory/$recordId");
    await updateAverageCpm(uid, db: db);
  }
}
