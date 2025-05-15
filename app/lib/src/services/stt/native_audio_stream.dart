import 'dart:async';
import 'package:flutter/services.dart';

class NativeAudioStream {
  static const _method = MethodChannel('native_audio_stream');
  static const _event = EventChannel('native_audio_stream_events');

  Stream<Uint8List> get audioStream =>
      _event.receiveBroadcastStream().map((event) => event as Uint8List);

  Future<void> start() async {
    await _method.invokeMethod('start');
  }

  Future<void> stop() async {
    await _method.invokeMethod('stop');
  }
}
