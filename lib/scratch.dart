import 'package:alarm/alarm.dart';
void main() {
  final settings = AlarmSettings(
    id: 1,
    dateTime: DateTime.now(),
    assetAudioPath: 'test.mp3',
    notificationTitle: 'Test',
    notificationBody: 'Test',
  );
  print(settings);
}
