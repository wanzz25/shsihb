import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'deploy',
      debugShowCheckedModeBanner: false,
      home: const WebViewPage(),
    );
  }
}

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    _requestFileAccessPermissions();

    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is AndroidWebViewPlatform) {
      params = AndroidWebViewControllerCreationParams();
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final webController = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://wanzz-deploy6788.vercel.app'));

    // Aktifkan file picker untuk <input type="file"> di website (Android):
    // ini yang bikin app bisa "akses file" — pilih file dari galeri/storage
    // untuk diupload lewat form website yang dibungkus.
    if (webController.platform is AndroidWebViewController) {
      final androidController = webController.platform as AndroidWebViewController;
      androidController.setOnShowFileSelector(_showFileSelector);
    }

    controller = webController;
  }

  Future<void> _requestFileAccessPermissions() async {
    // Minta izin akses file/media/kamera di awal supaya file picker &
    // input kamera dari website bisa langsung dipakai tanpa nge-block.
    await [
      Permission.camera,
      Permission.storage,
      Permission.photos,
      Permission.videos,
    ].request();
  }

  Future<List<String>> _showFileSelector(FileSelectorParams params) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: params.mode == FileSelectorMode.openMultiple,
      type: FileType.any,
    );
    if (result == null) return [];
    return result.paths
        .where((p) => p != null)
        .map((p) => Uri.file(p!).toString())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: WebViewWidget(controller: controller)),
    );
  }
}
