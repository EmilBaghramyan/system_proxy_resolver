#include <iostream>
#include <windows.h>
#include <winhttp.h>
#include "system_proxy_resolver.h"

HINTERNET hSession;

void initializeSystemProxyResolver(void* apiDlData) {
  Dart_InitializeApiDL(apiDlData);
  hSession = WinHttpOpen(
    L"",
    WINHTTP_ACCESS_TYPE_AUTOMATIC_PROXY,
    WINHTTP_NO_PROXY_NAME,
    WINHTTP_NO_PROXY_BYPASS,
    WINHTTP_FLAG_ASYNC);
}

static char* LPWSTRToCString(LPWSTR string) {
  int length = WideCharToMultiByte(CP_UTF8, 0, string, -1, 0, 0, NULL, NULL);
  char* output = new char[length];
  WideCharToMultiByte(CP_UTF8, 0, string, -1, output, length, NULL, NULL);
  return output;
}

static LPWSTR CStringToLPWSTR(char* input) {
  int lengthI = lstrlenA(input);
  int lengthO = MultiByteToWideChar(CP_UTF8, 0, input, lengthI, NULL, 0);
  wchar_t* output = new wchar_t[lengthO];
  //wchar_t* output = (wchar_t*)GlobalAlloc(GMEM_FIXED, lengthO);
  MultiByteToWideChar(CP_UTF8, 0, input, lengthI, output, lengthO);
  return output;
}

static bool Dart_PostGetProxyForUrlResult(Dart_Port_DL portId, GetProxyForUrlResult* value) {
  Dart_CObject object;
  object.type = Dart_CObject_kInt64;
  object.value.as_int64 = (intptr_t)value;
  return Dart_PostCObject_DL(portId, &object);
}

static bool Dart_PostGetProxyForUrlResultErrorCode(Dart_Port_DL portId, DWORD code) {
  GetProxyForUrlResult* result = new GetProxyForUrlResult();
  result->success = false;
  result->value.failure.type = FailureType_WindowsErrorCode;
  result->value.failure.value.windowsErrorCode = code;
  return Dart_PostGetProxyForUrlResult(portId, result);
}

static bool Dart_PostGetProxyForUrlResultMessage(Dart_Port_DL portId, char* message) {
  GetProxyForUrlResult* result = new GetProxyForUrlResult();
  result->success = false;
  result->value.failure.type = FailureType_Message;
  result->value.failure.value.message = message;
  return Dart_PostGetProxyForUrlResult(portId, result);
}

GetSystemProxySettingsResult* getSystemProxySettings() {
  GetSystemProxySettingsResult* result = new GetSystemProxySettingsResult();
  WINHTTP_CURRENT_USER_IE_PROXY_CONFIG proxyConfig = { 0 };

  if (WinHttpGetIEProxyConfigForCurrentUser(&proxyConfig)) {
    result->success = true;

    result->value.success.autoDiscoveryEnabled = proxyConfig.fAutoDetect;

    if (proxyConfig.lpszAutoConfigUrl != NULL) {
      result->value.success.autoConfigUrl = LPWSTRToCString(proxyConfig.lpszAutoConfigUrl);
      GlobalFree(proxyConfig.lpszAutoConfigUrl);
    }

    if (proxyConfig.lpszProxy != NULL) {
      result->value.success.httpProxy.host = LPWSTRToCString(proxyConfig.lpszProxy);
      result->value.success.httpsProxy.host = LPWSTRToCString(proxyConfig.lpszProxy);
      GlobalFree(proxyConfig.lpszProxy);
    }

    if (proxyConfig.lpszProxyBypass != NULL) {
      char** arr = new char*[1];
      result->value.success.bypassHostnames = arr;
      result->value.success.bypassHostnamesLength = 1;

      arr[0] = LPWSTRToCString(proxyConfig.lpszProxyBypass);
      GlobalFree(proxyConfig.lpszProxyBypass);
    }
  }
  else {
    result->success = false;

    result->value.failure.type = FailureType_WindowsErrorCode;
    result->value.failure.value.windowsErrorCode = GetLastError();
  }
  return result;
}

static char* strdup_cpp(const char* str) {
  int length = strlen(str);
  char* output = new char[length + 1];
  memcpy(output, str, length);
  output[length] = 0;
  return output;
}

static void reportGetProxyForUrlExError(Dart_Port_DL portId, DWORD errorCode) {
  char* message = NULL;

  switch (errorCode) {
  case ERROR_WINHTTP_AUTO_PROXY_SERVICE_ERROR:
    message = strdup_cpp("WinHttpGetProxyForUrlEx failed with error code ERROR_WINHTTP_AUTO_PROXY_SERVICE_ERROR");
    break;
  case ERROR_WINHTTP_BAD_AUTO_PROXY_SCRIPT:
    message = strdup_cpp("WinHttpGetProxyForUrlEx failed with error code ERROR_WINHTTP_BAD_AUTO_PROXY_SCRIPT");
    break;
  case ERROR_WINHTTP_INCORRECT_HANDLE_TYPE:
    message = strdup_cpp("WinHttpGetProxyForUrlEx failed with error code ERROR_WINHTTP_INCORRECT_HANDLE_TYPE");
    break;
  case ERROR_WINHTTP_INVALID_URL:
    message = strdup_cpp("WinHttpGetProxyForUrlEx failed with error code ERROR_WINHTTP_INVALID_URL");
    break;
  case ERROR_WINHTTP_OPERATION_CANCELLED:
    message = strdup_cpp("WinHttpGetProxyForUrlEx failed with error code ERROR_WINHTTP_OPERATION_CANCELLED");
    break;
  case ERROR_WINHTTP_UNABLE_TO_DOWNLOAD_SCRIPT:
    message = strdup_cpp("WinHttpGetProxyForUrlEx failed with error code ERROR_WINHTTP_UNABLE_TO_DOWNLOAD_SCRIPT");
    break;
  case ERROR_WINHTTP_UNRECOGNIZED_SCHEME:
    message = strdup_cpp("WinHttpGetProxyForUrlEx failed with error code ERROR_WINHTTP_UNRECOGNIZED_SCHEME");
    break;
  case ERROR_NOT_ENOUGH_MEMORY:
    message = strdup_cpp("WinHttpGetProxyForUrlEx failed with error code ERROR_NOT_ENOUGH_MEMORY");
    break;
  default:
    message = new char[100];
    sprintf(message, "WinHttpGetProxyForUrlEx failed with unknown error code %d", errorCode);
    break;
  }
  
  Dart_PostGetProxyForUrlResultMessage(portId, message);
}

static void getProxyForUrlCallback(
  HINTERNET hResolver,
  DWORD_PTR dwContext,
  DWORD dwInternetStatus,
  LPVOID lpvStatusInformation,
  DWORD dwStatusInformationLength
) {
  Dart_Port_DL port = (Dart_Port_DL)dwContext;

  if (dwInternetStatus == WINHTTP_CALLBACK_STATUS_REQUEST_ERROR) {
    WINHTTP_ASYNC_RESULT* asyncResult = (WINHTTP_ASYNC_RESULT*)lpvStatusInformation;

    if (asyncResult->dwResult != API_GET_PROXY_FOR_URL) {
      hResolver = NULL;
      goto quit;
    }
    Dart_PostGetProxyForUrlResultErrorCode(port, asyncResult->dwError);
  }
  else if (dwInternetStatus == WINHTTP_CALLBACK_STATUS_GETPROXYFORURL_COMPLETE)
  {
    WINHTTP_PROXY_RESULT proxyResult = { 0 };
    WinHttpGetProxyResult(hResolver, &proxyResult);

    GetProxyForUrlResult* result = new GetProxyForUrlResult();
    result->success = true;

    if (proxyResult.cEntries > 0) {
      WINHTTP_PROXY_RESULT_ENTRY entry = proxyResult.pEntries[0];
      if (entry.fProxy) {
        result->value.success.host = LPWSTRToCString(entry.pwszProxy);
        result->value.success.port = entry.ProxyPort;
      }
    }

    Dart_PostGetProxyForUrlResult(port, result);
  }
  else {
    hResolver = NULL;
  }

quit:
  if (hResolver != NULL) {
    WinHttpCloseHandle(hResolver);
  }
}

void getProxyForUrl(char* url, Dart_Port_DL port) {
  WINHTTP_CURRENT_USER_IE_PROXY_CONFIG ieProxyConfig = { 0 };
  WINHTTP_AUTOPROXY_OPTIONS autoProxyOptions = { 0 };
  HINTERNET hResolver = NULL;
  LPWSTR wUrl = NULL;

  if (!WinHttpGetIEProxyConfigForCurrentUser(&ieProxyConfig)) {
    Dart_PostGetProxyForUrlResultErrorCode(port, GetLastError());
    goto quit;
  }

  if (ieProxyConfig.lpszAutoConfigUrl)
  {
    autoProxyOptions.dwFlags = WINHTTP_AUTOPROXY_CONFIG_URL;
    autoProxyOptions.lpszAutoConfigUrl = ieProxyConfig.lpszAutoConfigUrl;
    autoProxyOptions.dwAutoDetectFlags = 0;
  }
  else
  {
    autoProxyOptions.dwFlags = WINHTTP_AUTOPROXY_AUTO_DETECT;
    autoProxyOptions.lpszAutoConfigUrl = NULL;
    autoProxyOptions.dwAutoDetectFlags = WINHTTP_AUTO_DETECT_TYPE_DHCP | WINHTTP_AUTO_DETECT_TYPE_DNS_A;
  }
  autoProxyOptions.fAutoLogonIfChallenged = true;
  
  DWORD resolverErrorCode = WinHttpCreateProxyResolver(hSession, &hResolver);
  if (resolverErrorCode != ERROR_SUCCESS) {
    Dart_PostGetProxyForUrlResultErrorCode(port, resolverErrorCode);
    goto quit;
  }

  WINHTTP_STATUS_CALLBACK callbackResult = WinHttpSetStatusCallback(
    hResolver,
    getProxyForUrlCallback,
    WINHTTP_CALLBACK_FLAG_REQUEST_ERROR | WINHTTP_CALLBACK_FLAG_GETPROXYFORURL_COMPLETE,
    0);
  if (callbackResult == WINHTTP_INVALID_STATUS_CALLBACK) {
    Dart_PostGetProxyForUrlResultErrorCode(port, GetLastError());
    goto quit;
  }

  wUrl = CStringToLPWSTR(url);
  DWORD getProxyErrorCode = WinHttpGetProxyForUrlEx(
    hResolver,
    wUrl,
    &autoProxyOptions,
    (DWORD_PTR)port);
  if (getProxyErrorCode != ERROR_IO_PENDING) {
    Dart_PostGetProxyForUrlResultErrorCode(port, getProxyErrorCode);
    goto quit;
  }

  // hResolver will be freed in callback
  hResolver = NULL;

quit:
  if (ieProxyConfig.lpszAutoConfigUrl != NULL) {
    GlobalFree(ieProxyConfig.lpszAutoConfigUrl);
  }
  if (ieProxyConfig.lpszProxy != NULL) {
    GlobalFree(ieProxyConfig.lpszProxy);
  }
  if (ieProxyConfig.lpszProxyBypass != NULL) {
    GlobalFree(ieProxyConfig.lpszProxyBypass);
  }
  if (hResolver != NULL) {
    WinHttpCloseHandle(hResolver);
  }
  if (wUrl != NULL) {
    delete[] wUrl;
  }
}

void freeGetSystemProxySettingsResult(GetSystemProxySettingsResult* result) {

}

void freeGetProxyForUrlResult(GetProxyForUrlResult* result) {

}
