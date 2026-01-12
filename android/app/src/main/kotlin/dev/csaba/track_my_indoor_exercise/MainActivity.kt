package dev.csaba.track_my_indoor_exercise

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.util.stream.Stream

class MainActivity: FlutterActivity() {
    private val BHT_CHANNEL = "com.trackmyindoorworkout/bht"
    private val BHT_STREAM_CHANNEL = "com.trackmyindoorworkout/bht/stream"
    private val ACTION_GET_DATA = "com.ailife.betterhealth.GET_DATA_API"
    private val ACTION_DATA_REPLY = "com.ailife.betterhealth.DATA_REPLY"
    private val EXTRA_DATA = "DATA"
    private val EXTRA_TYPE = "TYPE"
    private val VALUE_HR = "HR"
    private val VALUE_TYPE_NOW = "NOW"
    private val EXTRA_RESULT = "RESULT"
    private val EXTRA_RESULT_INSTANT = "RESULT_INSTANT"

    private var bhtReceiver: BhtBroadcastReceiver? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BHT_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "start") {
                if (bhtReceiver == null) {
                    val receiver = BhtBroadcastReceiver() // We will attach the sink later
                    // We can't attach sink here easily because MethodChannel doesn't own the EventSink.
                    // The design requires EventChannel to handle the sink.
                    // But we can trigger the broadcast REQUEST here.
                    sendBroadcast(Intent(ACTION_GET_DATA).apply {
                        putExtra(EXTRA_DATA, VALUE_HR)
                        putExtra(EXTRA_TYPE, VALUE_TYPE_NOW)
                    })
                    result.success(true)
                } else {
                    result.success(true)
                }
            } else if (call.method == "stop") {
                // We rely on EventChannel onCancel to clean up usually,
                // but explicit stop is fine too.
                result.success(true)
            } else {
                result.notImplemented()
            }
        }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, BHT_STREAM_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    if (bhtReceiver == null) {
                        bhtReceiver = BhtBroadcastReceiver()
                    }
                    bhtReceiver?.events = events
                    registerReceiver(bhtReceiver, IntentFilter(ACTION_DATA_REPLY))
                    
                    // Also trigger the request to start data flow
                    sendBroadcast(Intent(ACTION_GET_DATA).apply {
                        putExtra(EXTRA_DATA, VALUE_HR)
                        putExtra(EXTRA_TYPE, VALUE_TYPE_NOW)
                    })
                }

                override fun onCancel(arguments: Any?) {
                    if (bhtReceiver != null) {
                        unregisterReceiver(bhtReceiver)
                        bhtReceiver = null
                    }
                }
            }
        )
    }

    class BhtBroadcastReceiver : BroadcastReceiver() {
        var events: EventChannel.EventSink? = null

        override fun onReceive(context: Context, intent: Intent) {
            if (intent.action == "com.ailife.betterhealth.DATA_REPLY") {
                var hr = intent.getIntExtra("RESULT_INSTANT", 0)
                if (hr == 0) {
                     hr = intent.getIntExtra("RESULT", 0)
                }
                if (hr > 0) {
                    events?.success(hr)
                }
            }
        }
    }
}
