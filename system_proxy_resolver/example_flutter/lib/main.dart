import 'dart:async';

import 'package:flutter/material.dart';
import 'package:system_proxy_resolver/system_proxy_resolver.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const _widgetOptions = [
    SystemProxySettingsPage(),
    ProxyForUrlPage(),
  ];
  var _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: _widgetOptions[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: "System Settings",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: "Lookup",
            ),
          ],
          onTap: (index) => setState(() {
            _currentIndex = index;
          }),
        ),
      ),
    );
  }
}

class SystemProxySettingsPage extends StatefulWidget {
  const SystemProxySettingsPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SystemProxySettingsPageState();
}

class _SystemProxySettingsPageState extends State<SystemProxySettingsPage> {
  final _systemProxyResolverPlugin = SystemProxyResolver();
  late String _proxySettings;

  @override
  void initState() {
    super.initState();
    _refreshProxySettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("System Proxy Settings"),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_proxySettings, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => setState(() {
                _refreshProxySettings();
              }),
              child: const Icon(Icons.refresh),
            ),
          ],
        ),
      ),
    );
  }

  void _refreshProxySettings() {
    try {
      _proxySettings = _systemProxyResolverPlugin.getSystemProxySettings().toString();
    } on Object catch (e) {
      _proxySettings = e.toString();
    }
  }
}

class ProxyForUrlPage extends StatefulWidget {
  const ProxyForUrlPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProxyForUrlPageState();
}

class _ProxyForUrlPageState extends State<ProxyForUrlPage> {
  final _systemProxyResolverPlugin = SystemProxyResolver();
  final _controller = TextEditingController(text: "https://flutter.dev/");
  String? _response;
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Proxy Lookup"),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _controller,
              onSubmitted: (_) => _onLookup(),
            ),
            if (_response != null) ...[
              const SizedBox(height: 16),
              Text(_response!, textAlign: TextAlign.center),
            ],
            const SizedBox(height: 16),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _onLookup,
                child: const Icon(Icons.search),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _onLookup() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse(_controller.text.trim());
      final response = await _systemProxyResolverPlugin.getProxyForUrl(url).then((v) => v.toString());
      if (mounted) {
        setState(() {
          _response = response;
          _isLoading = false;
        });
      }
    } on Object catch (e) {
      if (mounted) {
        setState(() {
          _response = e.toString();
          _isLoading = false;
        });
      }
    }
  }
}
