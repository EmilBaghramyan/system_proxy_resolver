import 'dart:ffi' as ffi;
import 'dart:typed_data';

import 'package:system_proxy_resolver_foundation/src/core_foundation.g.dart';

final kCFStringEncodingUTF16Host = Endian.host == Endian.big ? kCFStringEncodingUTF16BE : kCFStringEncodingUTF16LE;

typedef CFTypeRef = ffi.Pointer<CFType>;

class CFType extends ffi.Opaque {}

extension CoreFoundationBindingsExtensions on CoreFoundationBindings {
  // ignore: non_constant_identifier_names
  void CFSafeRetain(CFTypeRef cf) {
    if (cf != ffi.nullptr) {
      CFRetain(cf);
    }
  }

  // ignore: non_constant_identifier_names
  void CFSafeRelease(CFTypeRef cf) {
    if (cf != ffi.nullptr) {
      CFRelease(cf);
    }
  }
}
