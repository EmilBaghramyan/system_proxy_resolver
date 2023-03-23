import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:system_proxy_resolver_foundation/src/core_foundation.g.dart';
import 'package:system_proxy_resolver_foundation/src/libs.dart';

extension PointerExtensions<T extends NativeType> on Pointer<T> {
  Pointer<T>? get nullIfNullptr => this == nullptr ? null : this;
}

extension CFTypeRefExtensions on CFTypeRef {
  int get retainCount => cfLib.CFGetRetainCount(this);

  String get description {
    final cfString = cfLib.CFCopyDescription(this);
    try {
      return cfString.toDartString();
    } finally {
      cfLib.CFSafeRelease(cfString.cast());
    }
  }

  Pointer<CFString>? asCFString() {
    if (this == nullptr) return null;
    return cfLib.CFGetTypeID(this) == cfLib.CFStringGetTypeID() ? cast() : null;
  }

  Pointer<CFNumber>? asCFNumber() {
    if (this == nullptr) return null;
    return cfLib.CFGetTypeID(this) == cfLib.CFNumberGetTypeID() ? cast() : null;
  }

  Pointer<CFBoolean>? asCFBoolean() {
    if (this == nullptr) return null;
    return cfLib.CFGetTypeID(this) == cfLib.CFBooleanGetTypeID() ? cast() : null;
  }

  Pointer<CFArray>? asCFArray() {
    if (this == nullptr) return null;
    return cfLib.CFGetTypeID(this) == cfLib.CFArrayGetTypeID() ? cast() : null;
  }

  Pointer<CFDictionary>? asCFDictionary() {
    if (this == nullptr) return null;
    return cfLib.CFGetTypeID(this) == cfLib.CFDictionaryGetTypeID() ? cast() : null;
  }
}

extension StringExtensions on String {
  Pointer<CFString> toCFString() {
    return using(
      (arena) {
        final units = codeUnits;
        final cStr = arena<Uint16>(units.length);
        final nativeString = cStr.asTypedList(units.length);
        nativeString.setAll(0, units);
        final result = cfLib.CFStringCreateWithBytes(
          cfLib.kCFAllocatorDefault,
          cStr.cast(),
          nativeString.lengthInBytes,
          kCFStringEncodingUTF16Host,
          false,
        );
        assert(result != nullptr);
        return result;
      },
      malloc,
    );
  }
}

extension CFStringRefExtensions on Pointer<CFString> {
  int get length => cfLib.CFStringGetLength(this);

  String toDartString() {
    assert(this != nullptr);
    return using(
      (arena) {
        final range = arena<CFRange>()
          ..ref.location = 0
          ..ref.length = length;
        final usedBufLen = arena<Long>()..value = 0;
        cfLib.CFStringGetBytes(this, range.ref, kCFStringEncodingUTF16Host, 0, false, nullptr, 0, usedBufLen);
        final buffer = arena<UnsignedChar>(usedBufLen.value);
        cfLib.CFStringGetBytes(
          this,
          range.ref,
          kCFStringEncodingUTF16Host,
          0,
          false,
          buffer,
          usedBufLen.value,
          nullptr,
        );
        final nativeString = buffer.cast<Uint8>().asTypedList(usedBufLen.value).buffer.asUint16List();
        return String.fromCharCodes(nativeString);
      },
      malloc,
    );
  }
}

extension CFDictionaryRefExtensions on Pointer<CFDictionary> {
  CFTypeRef getValue(CFTypeRef key) => cfLib.CFDictionaryGetValue(this, key.cast()).cast();
}

extension CFNumberRefExtensions on Pointer<CFNumber> {
  bool get boolValue {
    return using((arena) {
      final valuePtr = arena<Int8>();
      cfLib.CFNumberGetValue(this, kCFNumberSInt8Type, valuePtr.cast());
      return valuePtr.value != 0;
    });
  }

  int get unsignedShortValue {
    return using((arena) {
      final valuePtr = arena<UnsignedShort>();
      cfLib.CFNumberGetValue(this, kCFNumberShortType, valuePtr.cast());
      return valuePtr.value;
    });
  }
}

extension CFArrayExtensions on Pointer<CFArray> {
  int get count => cfLib.CFArrayGetCount(this);

  CFTypeRef getValue(int index) {
    assert(index >= 0 && index < count);
    return cfLib.CFArrayGetValueAtIndex(this, index).cast();
  }
}
