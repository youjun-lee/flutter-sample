package com.example.tosspayments

import android.content.ActivityNotFoundException
import android.content.Intent
import android.content.Intent.URI_INTENT_SCHEME
import android.net.Uri
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.net.URISyntaxException

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.flutter.tosspayments/sample23"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        GeneratedPluginRegistrant.registerWith(flutterEngine!!)
        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when {
                // Intent Url을 안드로이드 웹뷰에서 접근가능하도록 변환
                call.method.equals("getAppUrl") -> {
                    try {
                        val url: String = call.argument("url")!!
                        val intent = Intent.parseUri(url, URI_INTENT_SCHEME)
                        result.success(intent.dataString)
                    } catch (e: URISyntaxException) {
                        result.notImplemented()
                    } catch (e: ActivityNotFoundException) {
                        result.notImplemented()
                    }
                }

                // Intent Url을 playStore Market Url로 변환
                call.method.equals("getMarketUrl") -> {
                    try {
                        val url: String = call.argument("url")!!
                        val packageName = Intent.parseUri(url, URI_INTENT_SCHEME).getPackage()
                        val marketUrl = Intent(
                            Intent.ACTION_VIEW,
                            Uri.parse("market://details?id=$packageName")
                        )
                        result.success(marketUrl.dataString)
                    } catch (e: URISyntaxException) {
                        result.notImplemented()
                    } catch (e: ActivityNotFoundException) {
                        result.notImplemented()
                    }
                }
            }
        }
    }
}