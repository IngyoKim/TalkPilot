class ScriptPartModel {
  final String uid; // 참여자 uid
  final int startIndex; // 대본 시작 index
  final int endIndex; // 대본 끝 index

  ScriptPartModel({
    required this.uid,
    required this.startIndex,
    required this.endIndex,
  });

  factory ScriptPartModel.fromMap(Map<String, dynamic> map) {
    return ScriptPartModel(
      uid: map['uid'],
      startIndex: map['startIndex'],
      endIndex: map['endIndex'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'uid': uid, 'startIndex': startIndex, 'endIndex': endIndex};
  }
}
