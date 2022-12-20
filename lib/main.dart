import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Toss Payment Demo',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const MyHomePage(title: 'Flutter Toss Payment Demo Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const channel = const MethodChannel('com.flutter.tosspayments/sample23');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tosspayments Flutter Sample")),

      body: WebView(
        initialUrl: "[TODO] ## 웹뷰 주소 설정 ##",
        onPageStarted: (url) {},
        onPageFinished: (url) {},
        navigationDelegate: (request) async {
          Uri uri = Uri.parse(request.url);
          String finalUrl = request.url;
          log('youjun $finalUrl');

          // 웹뷰 브라우저에서 접근 가능한 주소(https 등)일 경우, 해당 url 로 이동
          if (uri.scheme == 'http' ||
              uri.scheme == 'https' ||
              uri.scheme == 'about') {
            return NavigationDecision.navigate;
          }
          log('youjun $finalUrl');

          // Intent URL일 경우, OS별로 구분하여 실행
          if (Platform.isAndroid) {
            //[NOTE] ANDROID의 경우, Native(Kotlin)으로 url을 전달해 INTENT처리 후 리턴받는다
            await _convertIntentToAppUrl(request.url).then((value) async {
              finalUrl = value;  // 앱이 설치되었을 경우
            });

            try{
              await launchUrlString(finalUrl);  // URL 실행 (dart Uri.parse가 대문자>소문자로 변환시켜, launchUrl 대신 launchUrlString 사용)
            }catch(e){  // URL 실행 불가 시, 앱 미설치로 판단하여 마켓 URL 실행
              finalUrl= await _convertIntentToMarketUrl(request.url);  //앱이 설치되어 있지 않을 경우, playstore로 이동
              launchUrlString(finalUrl);
            }

          }else if(Platform.isIOS){
            launchUrlString(finalUrl);  // URL 실행 (dart Uri.parse가 대문자>소문자로 변환시켜, launchUrl 대신 launchUrlString 사용)
          }

          return NavigationDecision.prevent;
        },
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }

  // Intent Url을 안드로이드 웹뷰에서 접근가능하도록 변환
  Future<String> _convertIntentToAppUrl(String text) async {
    return await channel.invokeMethod('getAppUrl',  <String, Object>{'url': text});
  }

  // Intent Url을 playStore Market Url로 변환
  Future<String> _convertIntentToMarketUrl(String text) async {
    return await channel.invokeMethod('getMarketUrl',  <String, Object>{'url': text});
  }
}