#include "system_proxy_resolver_windows.h"

static Dart_PostCObject_Type postCObject;
static HINTERNET hSession;

static BOOL initializeWinHttpSessionOnce(PINIT_ONCE InitOnce, PVOID Parameter, PVOID* Context) {
  postCObject = Parameter;
  hSession = WinHttpOpen(
    L"",
    WINHTTP_ACCESS_TYPE_AUTOMATIC_PROXY,
    WINHTTP_NO_PROXY_NAME,
    WINHTTP_NO_PROXY_BYPASS,
    WINHTTP_FLAG_ASYNC);
  return hSession != NULL;
}

FFI_PLUGIN_EXPORT HINTERNET initializeWinHttpSession(Dart_PostCObject_Type postCObject) {
  static INIT_ONCE once;
  InitOnceExecuteOnce(&once, initializeWinHttpSessionOnce, postCObject, NULL);
  return hSession;
}

static void winHttpStatusCallbackImpl(
  HINTERNET hInternet,
  DWORD_PTR dwContext,
  DWORD dwInternetStatus,
  LPVOID lpvStatusInformation,
  DWORD dwStatusInformationLength
) {
  WinHttpStatusCallbackResult* result = CoTaskMemAlloc(sizeof(WinHttpStatusCallbackResult));
  LPVOID lpvStatusInformationCopy = CoTaskMemAlloc(dwStatusInformationLength);
  if (result && lpvStatusInformationCopy) {
    memcpy(lpvStatusInformationCopy, lpvStatusInformation, dwStatusInformationLength);
    result->hInternet = hInternet;
    result->dwInternetStatus = dwInternetStatus;
    result->lpvStatusInformation = lpvStatusInformationCopy;
  }

  Dart_CObject* message = CoTaskMemAlloc(sizeof(Dart_CObject));
  if (message) {
    message->type = Dart_CObject_kInt64;
    message->value.as_int64 = (int64_t)result;
  }

  postCObject(dwContext, message);
  CoTaskMemFree(message);
}

FFI_PLUGIN_EXPORT WINHTTP_STATUS_CALLBACK winHttpStatusCallback = winHttpStatusCallbackImpl;

FFI_PLUGIN_EXPORT void freeWinHttpStatusCallbackResult(WinHttpStatusCallbackResult* result) {
  CoTaskMemFree(result->lpvStatusInformation);
  CoTaskMemFree(result);
}
