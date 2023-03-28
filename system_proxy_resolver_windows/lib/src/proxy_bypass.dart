class ProxyBypass {
  const ProxyBypass({required this.bypassHostnames, required this.bypassSimpleHostnames});

  final List<String> bypassHostnames;
  final bool bypassSimpleHostnames;
}
