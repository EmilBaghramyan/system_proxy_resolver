#import <Foundation/Foundation.h>
#include "system_proxy_resolver.h"

static CFRunLoopRef workerRunLoop;

@interface SystemProxyResolverRunner : NSObject
- (void)main;
@end

@implementation SystemProxyResolverRunner
- (void)main {
  workerRunLoop = CFRunLoopGetCurrent();
  
  while (true) {
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
  }
}
@end

void initializeSystemProxyResolver(void *apiDlData) {
  static dispatch_once_t once;
  dispatch_once(&once, ^{
    Dart_InitializeApiDL(apiDlData);
    
    SystemProxyResolverRunner *runner = [[SystemProxyResolverRunner alloc] init];
    NSThread *workerThread = [[NSThread alloc] initWithTarget:runner selector:@selector(main) object:nil];
    workerThread.name = @"system_proxy_resolver_worker";
    [workerThread start];
  });
}

static char *NSStringToCString(NSString *string) {
  if (string == nil) return NULL;
  NSUInteger length = [string lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
  char *str = malloc(length + 1);
  [string getCString:str maxLength:length + 1 encoding:NSUTF8StringEncoding];
  str[length] = 0;
  return str;
}

GetSystemProxySettingsResult *getSystemProxySettings() {
  NSDictionary *proxySettings = (__bridge_transfer NSDictionary *)CFNetworkCopySystemProxySettings();
  
  BOOL autoDiscoveryEnabled = ((NSNumber *)proxySettings[(__bridge NSString *)kCFNetworkProxiesProxyAutoDiscoveryEnable]).boolValue;
  
  BOOL autoConfigEnabled = ((NSNumber *)proxySettings[(__bridge NSString *)kCFNetworkProxiesProxyAutoConfigEnable]).boolValue;
  NSString *autoConfigURLString = proxySettings[(__bridge NSString *)kCFNetworkProxiesProxyAutoConfigURLString];
  
  BOOL httpEnable = ((NSNumber *)proxySettings[(__bridge NSString *)kCFNetworkProxiesHTTPEnable]).boolValue;
  NSString *httpHost = proxySettings[(__bridge NSString *)kCFNetworkProxiesHTTPProxy];
  uint16_t httpPort = ((NSNumber *)proxySettings[(__bridge NSString *)kCFNetworkProxiesHTTPPort]).unsignedShortValue;
  
  BOOL httpsEnable = ((NSNumber *)proxySettings[(__bridge NSString *)kCFNetworkProxiesHTTPSEnable]).boolValue;
  NSString *httpsHost = proxySettings[(__bridge NSString *)kCFNetworkProxiesHTTPSProxy];
  uint16_t httpsPort = ((NSNumber *)proxySettings[(__bridge NSString *)kCFNetworkProxiesHTTPSPort]).unsignedShortValue;
  
  BOOL ftpEnable = ((NSNumber *)proxySettings[(__bridge NSString *)kCFNetworkProxiesFTPEnable]).boolValue;
  NSString *ftpHost = proxySettings[(__bridge NSString *)kCFNetworkProxiesFTPProxy];
  uint16_t ftpPort = ((NSNumber *)proxySettings[(__bridge NSString *)kCFNetworkProxiesFTPPort]).unsignedShortValue;
  
  BOOL socksEnable = ((NSNumber *)proxySettings[(__bridge NSString *)kCFNetworkProxiesSOCKSEnable]).boolValue;
  NSString *socksHost = proxySettings[(__bridge NSString *)kCFNetworkProxiesSOCKSProxy];
  uint16_t socksPort = ((NSNumber *)proxySettings[(__bridge NSString *)kCFNetworkProxiesSOCKSPort]).unsignedShortValue;
  
  NSArray<NSString *> *exceptionsList = proxySettings[(__bridge NSString *)kCFNetworkProxiesExceptionsList];
  
  BOOL excludeSimpleHostnames = ((NSNumber *)proxySettings[(__bridge NSString *)kCFNetworkProxiesExcludeSimpleHostnames]).boolValue;
  
  GetSystemProxySettingsResult *result = calloc(1, sizeof(GetSystemProxySettingsResult));
  
  result->success = true;
  result->value.success.autoDiscoveryEnabled = autoDiscoveryEnabled;
  if (autoConfigEnabled) {
    result->value.success.autoConfigUrl = NSStringToCString(autoConfigURLString);
  }
  if (httpEnable) {
    result->value.success.httpProxy.type = ProxyType_Http;
    result->value.success.httpProxy.host = NSStringToCString(httpHost);
    result->value.success.httpProxy.port = httpPort;
  }
  if (httpsEnable) {
    result->value.success.httpProxy.type = ProxyType_Https;
    result->value.success.httpsProxy.host = NSStringToCString(httpsHost);
    result->value.success.httpsProxy.port = httpsPort;
  }
  if (ftpEnable) {
    result->value.success.ftpProxy.type = ProxyType_Ftp;
    result->value.success.ftpProxy.host = NSStringToCString(ftpHost);
    result->value.success.ftpProxy.port = ftpPort;
  }
  if (socksEnable) {
    result->value.success.socksProxy.type = ProxyType_Socks;
    result->value.success.socksProxy.host = NSStringToCString(socksHost);
    result->value.success.socksProxy.port = socksPort;
  }
  if (exceptionsList.count > 0) {
    result->value.success.bypassHostnamesLength = (unsigned int)exceptionsList.count;
    char **array = malloc(exceptionsList.count * sizeof(char *));
    result->value.success.bypassHostnames = array;
    
    for (int i = 0; i < exceptionsList.count; i++) {
      array[i] = NSStringToCString(exceptionsList[i]);
    }
  }
  result->value.success.bypassSimpleHostnames = excludeSimpleHostnames;
  
  return result;
}

static bool Dart_PostGetProxyForUrlResult(Dart_Port_DL portId, GetProxyForUrlResult *value) {
  Dart_CObject object;
  object.type = Dart_CObject_kInt64;
  object.value.as_int64 = (intptr_t)value;
  return Dart_PostCObject_DL(portId, &object);
}

static bool Dart_PostGetProxyForUrlFailureMessage(Dart_Port_DL portId, NSString *message) {
  GetProxyForUrlResult *result = calloc(1, sizeof(GetProxyForUrlResult));
  
  result->success = false;
  result->value.failure.type = FailureType_Message;
  result->value.failure.value.message = NSStringToCString(message);
  
  return Dart_PostGetProxyForUrlResult(portId, result);
}

static void processProxies(NSArray *proxies, NSURL *targetURL, Dart_Port_DL port);

static void getProxyForUrlCallback(void *client, CFArrayRef proxyList, CFErrorRef error) {
  Dart_Port_DL port = (Dart_Port_DL)client;
  
  if (proxyList != NULL) {
    processProxies((__bridge NSArray *)proxyList, nil, port);
  } else {
    NSString *errorMessage = [(__bridge NSError *)error description];
    Dart_PostGetProxyForUrlFailureMessage(port, errorMessage);
  }
}

static void processProxies(NSArray *proxies, NSURL *targetURL, Dart_Port_DL port) {
  unsigned int numberOfProxies = (unsigned int)proxies.count;
  Proxy *proxyArr = calloc(numberOfProxies, sizeof(Proxy));
  int index = 0;
  
  for (NSDictionary *proxyDict in proxies) {
    Proxy *proxy = &proxyArr[index];
    NSString *type = proxyDict[(__bridge NSString *)kCFProxyTypeKey];
    
    if ([type isEqualToString:(__bridge NSString *)kCFProxyTypeAutoConfigurationURL]) {
      NSURL *autoConfigurationURL = proxyDict[(__bridge NSURL *)kCFProxyAutoConfigurationURLKey];
      CFStreamClientContext context = { 0 };
      context.info = (void *)port;
      CFRunLoopSourceRef source = CFNetworkExecuteProxyAutoConfigurationURL((__bridge CFURLRef)autoConfigurationURL, (__bridge CFURLRef)targetURL, getProxyForUrlCallback, &context);
      CFRunLoopAddSource(workerRunLoop, source, kCFRunLoopDefaultMode);
      
      free(proxyArr);
      return;
    } else if ([type isEqualToString:(__bridge NSString *)kCFProxyTypeNone]) {
      index++;
      continue;
    } else if ([type isEqualToString:(__bridge NSString *)kCFProxyTypeHTTP]) {
      proxy->type = ProxyType_Http;
    } else if ([type isEqualToString:(__bridge NSString *)kCFProxyTypeHTTPS]) {
      proxy->type = ProxyType_Https;
    } else if ([type isEqualToString:(__bridge NSString *)kCFProxyTypeFTP]) {
      proxy->type = ProxyType_Ftp;
    } else if ([type isEqualToString:(__bridge NSString *)kCFProxyTypeSOCKS]) {
      proxy->type = ProxyType_Socks;
    } else {
      numberOfProxies--;
      continue;
    }
    
    NSString *proxyHost = proxyDict[(__bridge NSString *)kCFProxyHostNameKey];
    uint16_t proxyPort = ((NSNumber *)proxyDict[(__bridge NSString *)kCFProxyPortNumberKey]).unsignedShortValue;
    NSString *username = proxyDict[(__bridge NSString *)kCFProxyUsernameKey];
    NSString *password = proxyDict[(__bridge NSString *)kCFProxyPasswordKey];
    
    proxy->host = NSStringToCString(proxyHost);
    proxy->port = proxyPort;
    proxy->credentials.username = NSStringToCString(username);
    proxy->credentials.password = NSStringToCString(password);
  }
  
  GetProxyForUrlResult *result = calloc(1, sizeof(GetProxyForUrlResult));
  result->success = true;
  
  result->value.success.chainLength = numberOfProxies;
  result->value.success.chain = proxyArr;
  
  Dart_PostGetProxyForUrlResult(port, result);
}

void getProxyForUrl(char *url, Dart_Port_DL port) {
  NSURL *targetURL = [NSURL URLWithString:[NSString stringWithUTF8String:url]];
  CFDictionaryRef proxySettings = CFNetworkCopySystemProxySettings();
  NSArray *proxies = (__bridge_transfer NSArray *)CFNetworkCopyProxiesForURL((__bridge_retained CFURLRef)targetURL, proxySettings);
  CFRelease(proxySettings);
  
  processProxies(proxies, targetURL, port);
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
  free(proxy.host);
  free(proxy.credentials.username);
  free(proxy.credentials.password);
}

void freeGetSystemProxySettingsResult(GetSystemProxySettingsResult *result) {
  if (result->success) {
    free(result->value.success.autoConfigUrl);
    freeProxy(result->value.success.httpProxy);
    freeProxy(result->value.success.httpsProxy);
    freeProxy(result->value.success.ftpProxy);
    freeProxy(result->value.success.socksProxy);
    for (int i = 0; i < result->value.success.bypassHostnamesLength; i++) {
      free(result->value.success.bypassHostnames[i]);
    }
    free(result->value.success.bypassHostnames);
  } else {
    freeFailure(result->value.failure);
  }
  free(result);
}

void freeGetProxyForUrlResult(GetProxyForUrlResult *result) {
  if (result->success) {
    for (int i = 0; i < result->value.success.chainLength; i++) {
      freeProxy(result->value.success.chain[i]);
    }
  } else {
    freeFailure(result->value.failure);
  }
  free(result);
}
