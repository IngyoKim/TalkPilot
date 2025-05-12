package com.oss.talk_pilot

import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import android.os.Handler
import android.os.HandlerThread
import android.os.Looper
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class NativeAudioStreamPlugin : FlutterPlugin, EventChannel.StreamHandler {
    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel

    private var audioRecord: AudioRecord? = null
    private var recordingThread: HandlerThread? = null
    private var recordingHandler: Handler? = null
    private var eventSink: EventChannel.EventSink? = null
    private var isRecording = false

    private val sampleRate = 16000
    private val bufferSize = AudioRecord.getMinBufferSize(
        sampleRate,
        AudioFormat.CHANNEL_IN_MONO,
        AudioFormat.ENCODING_PCM_16BIT
    )

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel = MethodChannel(binding.binaryMessenger, "native_audio_stream")
        eventChannel = EventChannel(binding.binaryMessenger, "native_audio_stream_events")

        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "start" -> {
                    Log.d("NativeAudio", "start called")
                    startRecording()
                    result.success(null)
                }

                "stop" -> {
                    Log.d("NativeAudio", "stop called")
                    stopRecording()
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }

        eventChannel.setStreamHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        stopRecording()
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        Log.d("NativeAudio", "event channel started")
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        Log.d("NativeAudio", "event channel stopped")
        stopRecording()
        eventSink = null
    }

    private fun startRecording() {
        if (isRecording) return

        audioRecord = AudioRecord(
            MediaRecorder.AudioSource.MIC,
            sampleRate,
            AudioFormat.CHANNEL_IN_MONO,
            AudioFormat.ENCODING_PCM_16BIT,
            bufferSize
        )

        audioRecord?.startRecording()
        isRecording = true

        recordingThread = HandlerThread("AudioRecordingThread").apply { start() }
        recordingHandler = Handler(recordingThread!!.looper)

        recordingHandler?.post(object : Runnable {
            override fun run() {
                val buffer = ByteArray(bufferSize)
                val mainHandler = Handler(Looper.getMainLooper())

                while (isRecording) {
                    val read = audioRecord?.read(buffer, 0, buffer.size) ?: 0
                    if (read > 0) {
                        val chunk = buffer.copyOf(read)
                        mainHandler.post {
                            eventSink?.success(chunk)
                        }
                    }
                }
            }
        })
    }

    private fun stopRecording() {
        if (!isRecording) return

        isRecording = false
        audioRecord?.stop()
        audioRecord?.release()
        audioRecord = null

        recordingThread?.quitSafely()
        recordingThread = null
        recordingHandler = null
    }
}
