#include "dart_api_dl.h"

#if _WIN32
#define FFI_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FFI_PLUGIN_EXPORT __attribute__((visibility("default"))) __attribute__((used))
#endif

typedef enum
{
  FailureType_WindowsErrorCode,
  FailureType_Message,
} FailureType;

typedef struct
{
  FailureType type;
  union {
    unsigned long windowsErrorCode;
    char* message;
  } value;
} Failure;

typedef enum
{
  ProxyType_Direct,
  ProxyType_Http,
  ProxyType_Https,
  ProxyType_Ftp,
  ProxyType_Socks,
} ProxyType;

typedef struct
{
  char* username;
  char* password;
} ProxyCredentials;

typedef struct
{
  ProxyType type;
  char* host;
  uint16_t port;
  ProxyCredentials credentials;
} Proxy;

typedef struct
{
  bool autoDiscoveryEnabled;
  char* autoConfigUrl;
  Proxy httpProxy;
  Proxy httpsProxy;
  Proxy ftpProxy;
  Proxy socksProxy;
  char** bypassHostnames;
  unsigned int bypassHostnamesLength;
  bool bypassSimpleHostnames;
} SystemProxySettings;

typedef struct
{
  bool success;
  union {
    SystemProxySettings success;
    Failure failure;
  } value;
} GetSystemProxySettingsResult;

typedef struct {
  bool success;
  union {
    struct {
      unsigned int chainLength;
      Proxy *chain;
    } success;
    Failure failure;
  } value;
} GetProxyForUrlResult;

#if defined(__cplusplus)
extern "C" {
#endif

FFI_PLUGIN_EXPORT void initializeSystemProxyResolver(void* apiDlData);

FFI_PLUGIN_EXPORT GetSystemProxySettingsResult* getSystemProxySettings(void);

FFI_PLUGIN_EXPORT void getProxyForUrl(char* url, Dart_Port_DL port);

FFI_PLUGIN_EXPORT void freeGetSystemProxySettingsResult(GetSystemProxySettingsResult* result);

FFI_PLUGIN_EXPORT void freeGetProxyForUrlResult(GetProxyForUrlResult* result);

#if defined(__cplusplus)
}  // extern "C"
#endif
