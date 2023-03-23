#import <CoreFoundation/CoreFoundation.h>

#if _WIN32
#define FFI_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FFI_PLUGIN_EXPORT
#endif

typedef struct
{
  CFArrayRef proxyList;
  CFErrorRef error;
} CFProxyAutoConfigurationResult;
