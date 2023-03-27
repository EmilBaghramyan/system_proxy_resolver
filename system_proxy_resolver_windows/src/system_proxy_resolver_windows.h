#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <windows.h>
#include <winhttp.h>
#include "dart_api_dl.h"

#define FFI_PLUGIN_EXPORT __declspec(dllexport)

typedef struct {
  HINTERNET hInternet;
  DWORD dwInternetStatus;
  LPVOID lpvStatusInformation;
} WinHttpStatusCallbackResult;

FFI_PLUGIN_EXPORT WINHTTP_STATUS_CALLBACK winHttpStatusCallback;

FFI_PLUGIN_EXPORT HINTERNET initializeWinHttpSession(Dart_PostCObject_Type apiDlData);

FFI_PLUGIN_EXPORT void freeWinHttpStatusCallbackResult(WinHttpStatusCallbackResult* result);
