class SpeakerCpmResult {
  final String uid;
  String nickname;
  double userCpm;
  double actualCpm;
  String cpmStatus;

  SpeakerCpmResult({
    required this.uid,
    required this.nickname,
    required this.userCpm,
    required this.actualCpm,
    required this.cpmStatus,
  });
}
