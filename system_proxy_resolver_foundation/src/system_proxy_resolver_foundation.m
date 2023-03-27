#include "system_proxy_resolver_foundation.h"

static Dart_PostCObject_Type postCObject;
static dispatch_group_t workerWaitGroup;
static CFRunLoopRef workerRunLoop;

@interface SystemProxyResolverRunner : NSObject
- (void)main;
@end

@implementation SystemProxyResolverRunner
- (void)main {
  workerRunLoop = CFRunLoopGetCurrent();
  dispatch_group_leave(workerWaitGroup);
  
  while (true) {
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
  }
}
@end

FFI_PLUGIN_EXPORT void initializeProxyResolverRunLoop(Dart_PostCObject_Type postCObjectPtr, Dart_Port portId) {
  static dispatch_once_t once;
  dispatch_once(&once, ^{
    postCObject = postCObjectPtr;
    workerWaitGroup = dispatch_group_create();
    
    SystemProxyResolverRunner *runner = [[SystemProxyResolverRunner alloc] init];
    NSThread *workerThread = [[NSThread alloc] initWithTarget:runner selector:@selector(main) object:nil];
    workerThread.name = @"system_proxy_resolver_worker";
    dispatch_group_enter(workerWaitGroup);
    [workerThread start];
  });
  
  dispatch_group_notify(workerWaitGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    Dart_CObject message;
    message.type = Dart_CObject_kInt64;
    message.value.as_int64 = (int64_t)workerRunLoop;
    postCObject(portId, &message);
  });
}

static void proxyAutoConfigurationResultCallbackImpl(void *client, CFArrayRef proxyList, CFErrorRef error) {
  CFProxyAutoConfigurationResult *result = malloc(sizeof(CFProxyAutoConfigurationResult));
  result->proxyList = proxyList;
  result->error = error;
  
  Dart_CObject message;
  message.type = Dart_CObject_kInt64;
  message.value.as_int64 = (int64_t)result;
  
  if (postCObject((Dart_Port)client, &message)) {
    if (proxyList) CFRetain(proxyList);
    if (error) CFRetain(error);
  }
}

FFI_PLUGIN_EXPORT CFProxyAutoConfigurationResultCallback proxyAutoConfigurationResultCallback = proxyAutoConfigurationResultCallbackImpl;

FFI_PLUGIN_EXPORT void freeCFProxyAutoConfigurationResult(CFProxyAutoConfigurationResult *result) {
  free(result);
}
