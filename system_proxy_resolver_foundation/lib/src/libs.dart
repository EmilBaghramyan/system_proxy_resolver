import 'dart:ffi';

import 'package:system_proxy_resolver_foundation/src/core_foundation.g.dart';

final cfLib = CoreFoundationBindings(DynamicLibrary.process());
final helperLib = CoreFoundationBindings(DynamicLibrary.process());
