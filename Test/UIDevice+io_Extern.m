//
//  UIDevice+io_Extern.m
//  Test
//
//  Created by whf on 15/5/26.
//  Copyright (c) 2015年 whf. All rights reserved.
//

#import "UIDevice+io_Extern.h"

#import <sys/types.h>
#import <sys/sysctl.h>
#import <mach/mach_host.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <netdb.h>
#import <ifaddrs.h>
#import <sys/socket.h>
#import <net/if.h>
#import <net/if_dl.h>
#import <ifaddrs.h>
#import "CoreTelephony.h"

#pragma mark IOKit miniheaders

#define kIODeviceTreePlane        "IODeviceTree"

enum {
    kIORegistryIterateRecursively    = 0x00000001,
    kIORegistryIterateParents        = 0x00000002
};

typedef mach_port_t    io_object_t;
typedef io_object_t    io_registry_entry_t;
typedef char        io_name_t[128];
typedef UInt32        IOOptionBits;

CFTypeRef
IORegistryEntrySearchCFProperty(
                                io_registry_entry_t    entry,
                                const io_name_t        plane,
                                CFStringRef        key,
                                CFAllocatorRef        allocator,
                                IOOptionBits        options );

kern_return_t
IOMasterPort( mach_port_t    bootstrapPort,
             mach_port_t *    masterPort );

io_registry_entry_t
IORegistryGetRootEntry(
                       mach_port_t    masterPort );

CFTypeRef
IORegistryEntrySearchCFProperty(
                                io_registry_entry_t    entry,
                                const io_name_t        plane,
                                CFStringRef        key,
                                CFAllocatorRef        allocator,
                                IOOptionBits        options );

kern_return_t   mach_port_deallocate
(ipc_space_t                               task,
 mach_port_name_t                          name);


@implementation UIDevice (IOKit_Extensions)
#pragma mark IOKit Utils
NSArray *getValue(NSString *iosearch)
{
    mach_port_t          masterPort;
    CFTypeID             propID = (CFTypeID) NULL;
    unsigned int         bufSize;
    
    kern_return_t kr = IOMasterPort(MACH_PORT_NULL, &masterPort);
    if (kr != noErr) return nil;
    
    io_registry_entry_t entry = IORegistryGetRootEntry(masterPort);
    if (entry == MACH_PORT_NULL) return nil;
    
    CFTypeRef prop = IORegistryEntrySearchCFProperty(entry, kIODeviceTreePlane, (__bridge CFStringRef) iosearch, nil, kIORegistryIterateRecursively);
    if (!prop) return nil;
    
    propID = CFGetTypeID(prop);
    if (!(propID == CFDataGetTypeID()))
    {
        mach_port_deallocate(mach_task_self(), masterPort);
        return nil;
    }
    
    CFDataRef propData = (CFDataRef) prop;
    if (!propData) return nil;
    
    bufSize = CFDataGetLength(propData);
    if (!bufSize) return nil;
    
    NSString *p1 = [[NSString alloc] initWithBytes:CFDataGetBytePtr(propData) length:bufSize encoding:1];
    mach_port_deallocate(mach_task_self(), masterPort);
    return [p1 componentsSeparatedByString:@"/0"];
}

- (NSString *) imei
{
//    NSArray *results = getValue(@"device-imei");
//    if (results) return [results objectAtIndex:0];
    
    return [self coreTelephonyInfoForKey:@"kCTMobileEquipmentInfoIMEI"];
}

- (NSString *) serialNumber
{
    NSArray *results = getValue(@"serial-number");
    if (results) return [results objectAtIndex:0];
    return nil;
}

- (NSString *) backlightLevel
{
    NSArray *results = getValue(@"backlight-level");
    if (results) return [results objectAtIndex:0];
    return nil;
}

CTServerConnectionRef conn;
void ConnectionCallback(CTServerConnectionRef connection, CFStringRef string, CFDictionaryRef dictionary, void *data) {
    NSLog(@"ConnectionCallback");
    CFShow(dictionary);
}

- (NSString *)coreTelephonyInfoForKey:(const NSString *)key {
    NSString *retVal = nil;
    conn = _CTServerConnectionCreate(kCFAllocatorDefault, ConnectionCallback,NULL);
    if (conn) {
        struct CTResult result;
        CFMutableDictionaryRef equipmentInfo = nil;
        _CTServerConnectionCopyMobileEquipmentInfo(&result, conn, &equipmentInfo);
        if (equipmentInfo) {
            retVal = [NSString stringWithString:CFDictionaryGetValue(equipmentInfo, (__bridge const void *)(key))];
            CFRelease(equipmentInfo);
        }
        CFRelease(conn);
    }
    return retVal;
}

- (NSString *)macAddress
{
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        free(buf);
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    printf("ptr:%c",*ptr) ;
    NSString *outstring = [NSString stringWithFormat:@"X:X:X:X:X:X",
        *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    
    return outstring;
}
@end