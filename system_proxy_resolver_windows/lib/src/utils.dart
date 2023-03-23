import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:system_proxy_resolver_windows/src/winhttp.g.dart';
import 'package:win32/win32.dart';

// ignore: non_constant_identifier_names
int GlobalSafeFree(Pointer hMem) {
  if (hMem != nullptr) {
    return GlobalFree(hMem.address);
  } else {
    return nullptr.address;
  }
}

extension PointerExtensions<T extends NativeType> on Pointer<T> {
  Pointer<T>? get nullIfNullptr => this == nullptr ? null : this;
}

extension StringExtensions on String {
  Pointer<WChar> toLPWSTR({Allocator allocator = malloc}) => toNativeUtf16(allocator: allocator).cast();
}

extension LPWSTRExtensions on Pointer<WChar> {
  String toDartString({int? length}) => cast<Utf16>().toDartString(length: length);
}

// ignore: camel_case_extensions
extension WINHTTP_CURRENT_USER_IE_PROXY_CONFIGExtensions on Pointer<WINHTTP_CURRENT_USER_IE_PROXY_CONFIG> {
  void addTo(Arena arena) {
    arena.onReleaseAll(() {
      GlobalSafeFree(ref.lpszAutoConfigUrl);
      GlobalSafeFree(ref.lpszProxy);
      GlobalSafeFree(ref.lpszProxyBypass);
    });
  }
}
