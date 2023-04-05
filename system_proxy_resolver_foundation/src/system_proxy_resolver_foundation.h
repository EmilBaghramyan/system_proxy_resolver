#import <CoreFoundation/CoreFoundation.h>
#import <CFNetwork/CFProxySupport.h>
#include "dart_api_dl.h"

#define FFI_PLUGIN_EXPORT

typedef struct
{
  CFArrayRef proxyList;
  CFErrorRef error;
} CFProxyAutoConfigurationResult;

FFI_PLUGIN_EXPORT void initializeProxyResolverRunLoop(Dart_PostCObject_Type postCObject, Dart_Port portId);

FFI_PLUGIN_EXPORT CFProxyAutoConfigurationResultCallback proxyAutoConfigurationResultCallback;

FFI_PLUGIN_EXPORT void freeCFProxyAutoConfigurationResult(CFProxyAutoConfigurationResult* result);
