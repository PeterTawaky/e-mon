import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_static/shelf_static.dart';
import 'package:webview_windows/webview_windows.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Mall3DTestApp());
}

class Mall3DTestApp extends StatelessWidget {
  const Mall3DTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mall 3D Test',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const Mall3DTestPage(),
    );
  }
}

class Mall3DTestPage extends StatefulWidget {
  const Mall3DTestPage({super.key});

  @override
  State<Mall3DTestPage> createState() => _Mall3DTestPageState();
}

class _Mall3DTestPageState extends State<Mall3DTestPage> {
  static const int _port = 8088;

  WebviewController? _controller;
  HttpServer? _server;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    if (!Platform.isWindows) {
      _showError(
        'This 3D test is Windows-only.\n\n'
        'Run it with:\n'
        'flutter run -d windows -t lib/main_3d_test.dart',
      );
      return;
    }

    _startViewer();
  }

  Future<void> _startViewer() async {
    try {
      final webViewVersion = await WebviewController.getWebViewVersion();

      if (webViewVersion == null) {
        _showError(
          'Microsoft Edge WebView2 Runtime is not installed.\n'
          'Install WebView2 Runtime, then run the test again.',
        );
        return;
      }

      final webFolderPath = '${Directory.current.path}\\local_web';
      final webFolder = Directory(webFolderPath);

      if (!webFolder.existsSync()) {
        _showError('local_web folder not found:\n$webFolderPath');
        return;
      }

      final modelFile = File('$webFolderPath\\models\\mall.glb');

      if (!modelFile.existsSync()) {
        _showError('3D model file not found:\n${modelFile.path}');
        return;
      }

      _server = await shelf_io.serve(
        createStaticHandler(webFolderPath, defaultDocument: 'viewer.html'),
        InternetAddress.loopbackIPv4,
        _port,
      );

      final controller = WebviewController();
      _controller = controller;

      await controller.initialize();
      await controller.setBackgroundColor(Colors.black);
      await controller.setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);
      await controller.loadUrl('http://127.0.0.1:$_port/viewer.html');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    } on PlatformException catch (error) {
      if (error.code == 'unsupported_platform') {
        _showError(
          'Unsupported platform.\n\n'
          'Run this test on Windows desktop only:\n'
          'flutter run -d windows -t lib/main_3d_test.dart',
        );
        return;
      }

      _showError(error.toString());
    } catch (error) {
      _showError(error.toString());
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _errorMessage = message;
    });
  }

  Future<void> _reloadViewer() async {
    final controller = _controller;

    if (controller != null && controller.value.isInitialized) {
      await controller.reload();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _server?.close(force: true);
    super.dispose();
  }

  Widget _buildBody() {
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.redAccent, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading 3D model...'),
          ],
        ),
      );
    }

    final controller = _controller;

    if (controller == null) {
      return const Center(child: Text('WebView is not available.'));
    }

    return ValueListenableBuilder<WebviewValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        if (!value.isInitialized) {
          return const Center(child: Text('WebView is initializing...'));
        }

        return Stack(
          children: [
            Webview(controller),
            StreamBuilder<LoadingState>(
              stream: controller.loadingState,
              builder: (context, snapshot) {
                if (snapshot.data == LoadingState.loading) {
                  return const LinearProgressIndicator();
                }

                return const SizedBox.shrink();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Mall 3D Test - Windows'),
        actions: [
          IconButton(
            tooltip: 'Reload model',
            onPressed: _reloadViewer,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }
}
