import 'package:talk_pilot/src/models/cpm_record_model.dart';
import 'package:talk_pilot/src/services/database/database_service.dart';
import 'package:talk_pilot/src/services/database/user_service.dart';

extension CpmHistoryService on UserService {
  static final _cpmDb = DatabaseService();

  Future<void> addCpmRecord(String uid, CpmRecordModel record) async {
    final recordId = record.timestamp.millisecondsSinceEpoch.toString();
    await _cpmDb.writeDB("users/$uid/cpmHistory/$recordId", record.toMap());
  }

  Future<List<CpmRecordModel>> getCpmHistory(String uid) async {
    return _cpmDb.fetchDB<CpmRecordModel>(
      path: "users/$uid/cpmHistory",
      fromMap: (map) => CpmRecordModel.fromMap(map),
    );
  }

  Future<void> updateAverageCpm(String uid) async {
    final history = await getCpmHistory(uid);
    if (history.isEmpty) return;

    final avg =
        history.map((e) => e.cpm).reduce((a, b) => a + b) / history.length;
    await updateUser(uid, {'averageCpm': avg});
  }
}
