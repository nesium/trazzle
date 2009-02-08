#ifndef TRAZZLE_ERROR_DOMAIN
#define TRAZZLE_ERROR_DOMAIN @"TrazzleErrorDomain"
#endif

#ifndef TRAZZLE_APP_SUPPORT
#define TRAZZLE_APP_SUPPORT [[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Trazzle"]
#endif