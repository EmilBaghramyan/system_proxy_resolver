#include <windows.h>
#include <winhttp.h>
#include <vector>
#include "system_proxy_resolver.h"

static HINTERNET hSession;

static BOOL initializeSystemProxyResolverOnce(PINIT_ONCE InitOnce, PVOID Parameter, PVOID* Contex) {
  Dart_InitializeApiDL(Parameter);
  hSession = WinHttpOpen(
    L"",
    WINHTTP_ACCESS_TYPE_AUTOMATIC_PROXY,
    WINHTTP_NO_PROXY_NAME,
    WINHTTP_NO_PROXY_BYPASS,
    WINHTTP_FLAG_ASYNC);
  return TRUE;
}

void initializeSystemProxyResolver(void* apiDlData) {
  static INIT_ONCE once;
  InitOnceExecuteOnce(&once, initializeSystemProxyResolverOnce, apiDlData, NULL);
}

static char* WCSToCStr(LPWSTR string) {
  int length = WideCharToMultiByte(CP_UTF8, 0, string, -1, 0, 0, NULL, NULL);
  char* output = new char[length];
  WideCharToMultiByte(CP_UTF8, 0, string, -1, output, length, NULL, NULL);
  return output;
}

static LPWSTR CStrToWCS(char* input) {
  int lengthI = lstrlenA(input);
  int lengthO = MultiByteToWideChar(CP_UTF8, 0, input, lengthI, NULL, 0);
  wchar_t* output = new wchar_t[lengthO];
  MultiByteToWideChar(CP_UTF8, 0, input, lengthI, output, lengthO);
  return output;
}

static bool Dart_PostGetProxyForUrlResult(Dart_Port_DL portId, GetProxyForUrlResult* value) {
  Dart_CObject object;
  object.type = Dart_CObject_kInt64;
  object.value.as_int64 = (intptr_t)value;
  return Dart_PostCObject_DL(portId, &object);
}

static bool Dart_PostGetProxyForUrlErrorCode(Dart_Port_DL portId, DWORD code) {
  GetProxyForUrlResult* result = new GetProxyForUrlResult();
  result->success = false;
  result->value.failure.type = FailureType_WindowsErrorCode;
  result->value.failure.value.windowsErrorCode = code;
  return Dart_PostGetProxyForUrlResult(portId, result);
}

static char* strdup_cpp(char* input) {
  if (input == NULL) return NULL;
  auto length = strlen(input);
  auto output = new char[length + 1];
  output[length] = 0;
  memcpy(output, input, length * sizeof(char));
  return output;
}

static void parseProxyString(LPWSTR lpszProxy, Proxy* proxy) {
  wchar_t* buffer = NULL;
  wchar_t* token = wcstok_s(lpszProxy, L":", &buffer);
  int i = 0;

  while (token != NULL) {
    switch (i++) {
    case 0:
      proxy->host = WCSToCStr(token);
      break;
    case 1:
      proxy->port = (uint16_t)wcstol(token, NULL, 10);
      break;
    }
    token = wcstok_s(NULL, L":", &buffer);
  }
}

static void parseProxiesString(LPWSTR lpszProxy, SystemProxySettings* settings) {
  if (wcschr(lpszProxy, L'=') == NULL) {
    parseProxyString(lpszProxy, &settings->httpProxy);
    if (settings->httpProxy.host != NULL) {
      settings->httpProxy.type = ProxyType_Http;

      settings->httpsProxy.type = ProxyType_Https;
      settings->httpsProxy.host = strdup_cpp(settings->httpProxy.host);
      settings->httpsProxy.port = settings->httpProxy.port;

      settings->ftpProxy.type = ProxyType_Ftp;
      settings->ftpProxy.host = strdup_cpp(settings->httpProxy.host);
      settings->ftpProxy.port = settings->httpProxy.port;
    }
    return;
  }

  wchar_t* semicolonBuffer = NULL;
  wchar_t* semicolonToken = wcstok_s(lpszProxy, L";", &semicolonBuffer);
  while (semicolonToken != NULL) {
    wchar_t* equalsBuffer = NULL;
    wchar_t* equalsToken = wcstok_s(semicolonToken, L"=", &equalsBuffer);
    int i = 0;
    Proxy* proxy = NULL;

    while (equalsToken != NULL) {
      switch (i++) {
      case 0:
        if (wcscmp(equalsToken, L"http") == 0) {
          proxy = &settings->httpProxy;
          proxy->type = ProxyType_Http;
        }
        else if (wcscmp(equalsToken, L"https") == 0) {
          proxy = &settings->httpsProxy;
          proxy->type = ProxyType_Https;
        }
        else if (wcscmp(equalsToken, L"ftp") == 0) {
          proxy = &settings->ftpProxy;
          proxy->type = ProxyType_Ftp;
        }
        else if (wcscmp(equalsToken, L"socks") == 0) {
          proxy = &settings->socksProxy;
          proxy->type = ProxyType_Socks;
        }
        break;
      case 1:
        if (proxy != NULL) {
          parseProxyString(equalsToken, proxy);
        }
        break;
      }

      equalsToken = wcstok_s(NULL, L"=", &equalsBuffer);
    }

    semicolonToken = wcstok_s(NULL, L";", &semicolonBuffer);
  }
}

static void parseProxyBypass(LPWSTR lpszProxyBypass, SystemProxySettings* settings) {
  std::vector<char*> hostnames;
  wchar_t* buffer = NULL;
  wchar_t* token = wcstok_s(lpszProxyBypass, L";", &buffer);

  while (token != NULL) {
    if (wcscmp(token, L"<local>") == 0) {
      settings->bypassSimpleHostnames = true;
    }
    else {
      hostnames.push_back(WCSToCStr(token));
    }
    token = wcstok_s(NULL, L";", &buffer);
  }

  char** arr = new char* [hostnames.size()];
  std::copy(hostnames.begin(), hostnames.end(), arr);

  settings->bypassHostnames = arr;
  settings->bypassHostnamesLength = (unsigned int)hostnames.size();
}

GetSystemProxySettingsResult* getSystemProxySettings() {
  GetSystemProxySettingsResult* result = new GetSystemProxySettingsResult();
  WINHTTP_CURRENT_USER_IE_PROXY_CONFIG proxyConfig = { 0 };

  if (WinHttpGetIEProxyConfigForCurrentUser(&proxyConfig)) {
    result->success = true;

    result->value.success.autoDiscoveryEnabled = proxyConfig.fAutoDetect;

    if (proxyConfig.lpszAutoConfigUrl != NULL) {
      result->value.success.autoConfigUrl = WCSToCStr(proxyConfig.lpszAutoConfigUrl);
      GlobalFree(proxyConfig.lpszAutoConfigUrl);
    }

    if (proxyConfig.lpszProxy != NULL) {
      parseProxiesString(proxyConfig.lpszProxy, &result->value.success);
      GlobalFree(proxyConfig.lpszProxy);
    }

    if (proxyConfig.lpszProxyBypass != NULL) {
      parseProxyBypass(proxyConfig.lpszProxyBypass, &result->value.success);
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
    Dart_PostGetProxyForUrlErrorCode(port, asyncResult->dwError);
  }
  else if (dwInternetStatus == WINHTTP_CALLBACK_STATUS_GETPROXYFORURL_COMPLETE)
  {
    WINHTTP_PROXY_RESULT proxyResult = { 0 };
    WinHttpGetProxyResult(hResolver, &proxyResult);

    unsigned int numberOfProxies = proxyResult.cEntries;
    Proxy* proxyArr = new Proxy[numberOfProxies]();

    for (DWORD entryIndex = 0, proxyIndex = 0; entryIndex < proxyResult.cEntries; entryIndex++, proxyIndex++) {
      WINHTTP_PROXY_RESULT_ENTRY entry = proxyResult.pEntries[entryIndex];
      Proxy* proxy = &proxyArr[proxyIndex];

      if (!entry.fProxy) {
        continue;
      }

      switch (entry.ProxyScheme) {
      case INTERNET_SCHEME_HTTP:
        proxy->type = ProxyType_Http;
        break;
      case INTERNET_SCHEME_HTTPS:
        proxy->type = ProxyType_Https;
        break;
      case INTERNET_SCHEME_FTP:
        proxy->type = ProxyType_Ftp;
        break;
      case INTERNET_SCHEME_SOCKS:
        proxy->type = ProxyType_Socks;
        break;
      default:
        numberOfProxies--;
        proxyIndex--;
        continue;
      }

      proxy->host = WCSToCStr(entry.pwszProxy);
      proxy->port = entry.ProxyPort;
    }

    WinHttpFreeProxyResult(&proxyResult);

    GetProxyForUrlResult* result = new GetProxyForUrlResult();

    result->success = true;
    result->value.success.chainLength = numberOfProxies;
    result->value.success.chain = proxyArr;

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
    Dart_PostGetProxyForUrlErrorCode(port, GetLastError());
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
    Dart_PostGetProxyForUrlErrorCode(port, resolverErrorCode);
    goto quit;
  }

  WINHTTP_STATUS_CALLBACK callbackResult = WinHttpSetStatusCallback(
    hResolver,
    getProxyForUrlCallback,
    WINHTTP_CALLBACK_FLAG_REQUEST_ERROR | WINHTTP_CALLBACK_FLAG_GETPROXYFORURL_COMPLETE,
    0);
  if (callbackResult == WINHTTP_INVALID_STATUS_CALLBACK) {
    Dart_PostGetProxyForUrlErrorCode(port, GetLastError());
    goto quit;
  }

  wUrl = CStrToWCS(url);
  DWORD getProxyErrorCode = WinHttpGetProxyForUrlEx(
    hResolver,
    wUrl,
    &autoProxyOptions,
    (DWORD_PTR)port);
  if (getProxyErrorCode != ERROR_IO_PENDING) {
    Dart_PostGetProxyForUrlErrorCode(port, getProxyErrorCode);
    goto quit;
  }

  // hResolver will be freed in the async callback
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

static void freeFailure(Failure failure) {
  switch (failure.type) {
  case FailureType_WindowsErrorCode:
    break;
  case FailureType_Message:
    free(failure.value.message);
    break;
  }
}

static void freeProxy(Proxy proxy) {
  delete[] proxy.host;
  delete[] proxy.credentials.username;
  delete[] proxy.credentials.password;
}

void freeGetSystemProxySettingsResult(GetSystemProxySettingsResult* result) {
  if (result->success) {
    delete[] result->value.success.autoConfigUrl;
    freeProxy(result->value.success.httpProxy);
    freeProxy(result->value.success.httpsProxy);
    freeProxy(result->value.success.ftpProxy);
    freeProxy(result->value.success.socksProxy);
    for (unsigned int i = 0; i < result->value.success.bypassHostnamesLength; i++) {
      delete[] result->value.success.bypassHostnames[i];
    }
    delete[] result->value.success.bypassHostnames;
  }
  else {
    freeFailure(result->value.failure);
  }
  delete[] result;
}

void freeGetProxyForUrlResult(GetProxyForUrlResult* result) {
  if (result->success) {
    for (unsigned int i = 0; i < result->value.success.chainLength; i++) {
      freeProxy(result->value.success.chain[i]);
    }
  }
  else {
    freeFailure(result->value.failure);
  }
  delete[] result;
}
