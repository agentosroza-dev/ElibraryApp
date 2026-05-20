import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../config/theme.dart';

class ReadBookScreen extends StatefulWidget {
  final String url;
  final String? title;

  const ReadBookScreen({
    super.key,
    required this.url,
    this.title,
  });

  @override
  State<ReadBookScreen> createState() => _ReadBookScreenState();
}

class _ReadBookScreenState extends State<ReadBookScreen> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            _injectToken();
          },
          onPageFinished: (_) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _hasError = false;
              });
            }
          },
          onWebResourceError: (_) {
            if (mounted) setState(() => _hasError = true);
          },
        ),
      );

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUrl());
  }

  Future<void> _loadUrl() async {
    try {
      await _controller.loadRequest(Uri.parse(widget.url));
    } catch (_) {
      if (mounted) setState(() => _hasError = true);
    }
  }

  Future<void> _injectToken() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) return;
      final escaped = token.replaceAll("'", "\\'");
      await _controller.runJavaScript(
        "localStorage.setItem('token', '$escaped');"
        "console.log('Auth token injected');",
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title ?? 'Reading',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: () => _controller.reload(),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: isDark ? AppColors.iosBackgroundDark : AppColors.iosCardLight,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: cs.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Loading...',
                      style: TextStyle(
                        color: AppColors.iosGray,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_hasError)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: cs.error.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Icon(
                        Icons.error_outline,
                        size: 32,
                        color: cs.error.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Failed to load page',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _hasError = false;
                          _isLoading = true;
                        });
                        _loadUrl();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
