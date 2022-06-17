import 'package:na0826/widgets/responsive_safe_area.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';



class WebVewApp extends StatefulWidget {
  final String? title;
  final String url;
  const WebVewApp({Key? key,
    this.title, required this.url,
  }) : super(key: key);

  @override
  _WebVewAppState createState() => _WebVewAppState();
}

class _WebVewAppState extends State<WebVewApp> {


  late WebViewController _controller;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = AndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveSafeArea(
      builder: (_) => Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(widget.title??''),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          // backgroundColor: const Color(0xFF101010),
        ),
        backgroundColor: const Color(0xFF101010),
        body: WebView(
          javascriptMode: JavascriptMode.unrestricted,
          initialUrl: widget.url,
          onWebViewCreated: (controller) {
            _controller = controller;
          },
        ),
      ),
    );
  }
}

