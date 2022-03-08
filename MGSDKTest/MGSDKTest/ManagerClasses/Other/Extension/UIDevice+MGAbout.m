//
//  UIDevice+MGAbout.m
//  TestTable
//
//  Created by Inder Kumar Rathore on 19/01/13.
//  Copyright (c) 2013 Rathore. All rights reserved.
//

#import "UIDevice+MGAbout.h"
#include <sys/sysctl.h>

#include <net/if.h>
#include <net/if_dl.h>

#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import "MGKeyChain.h"

@implementation UIDevice (MGHardware)

- (NSString*)hardwareString {
  int name[] = {CTL_HW,HW_MACHINE};
  size_t size = 100;
  sysctl(name, 2, NULL, &size, NULL, 0); // getting size of answer
  char *hw_machine = malloc(size);

  sysctl(name, 2, hw_machine, &size, NULL, 0);
  NSString *hardware = [NSString stringWithUTF8String:hw_machine];
  free(hw_machine);
  return hardware;
}

- (NSString*)hardwareSimpleDescription
{
  NSString *hardware = [self hardwareString];
    if ([hardware isEqualToString:@"iPhone1,1"])    return @"iPhone 2G";
    if ([hardware isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([hardware isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([hardware isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([hardware isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([hardware isEqualToString:@"iPhone3,3"])    return @"iPhone 4";
    if ([hardware isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([hardware isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([hardware isEqualToString:@"iPhone5,2"])    return @"iPhone 5";
    if ([hardware isEqualToString:@"iPhone5,3"])    return @"iPhone 5C";
    if ([hardware isEqualToString:@"iPhone5,4"])    return @"iPhone 5C";
    if ([hardware isEqualToString:@"iPhone6,1"])    return @"iPhone 5S";
    if ([hardware isEqualToString:@"iPhone6,2"])    return @"iPhone 5S";
    
    if ([hardware isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([hardware isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    
    if ([hardware isEqualToString:@"iPhone8,1"]) return @"iPhone 6s";
    if ([hardware isEqualToString:@"iPhone8,2"]) return @"iPhone 6s Plus";
    if ([hardware isEqualToString:@"iPhone8,3"]) return @"iPhone SE";
    if ([hardware isEqualToString:@"iPhone8,4"]) return @"iPhone SE";
    if ([hardware isEqualToString:@"iPhone9,1"]) return @"iPhone 7";
    if ([hardware isEqualToString:@"iPhone9,3"]) return @"iPhone 7";
    if ([hardware isEqualToString:@"iPhone9,2"]) return @"iPhone 7 Plus";
    if ([hardware isEqualToString:@"iPhone9,4"]) return @"iPhone 7 Plus";
    if ([hardware isEqualToString:@"iPhone10,1"]) return @"iPhone 8";
    if ([hardware isEqualToString:@"iPhone10,4"]) return @"iPhone 8";
    if ([hardware isEqualToString:@"iPhone10,2"]) return @"iPhone 8 Plus";
    if ([hardware isEqualToString:@"iPhone10,5"]) return @"iPhone 8 Plus";
    if ([hardware isEqualToString:@"iPhone10,3"]) return @"iPhone X";
    if ([hardware isEqualToString:@"iPhone10,6"]) return @"iPhone X";
    if ([hardware isEqualToString:@"iPhone11,8"]) return @"iPhone XR";
    if ([hardware isEqualToString:@"iPhone11,2"]) return @"iPhone XS";
    if ([hardware isEqualToString:@"iPhone11,4"] || [hardware isEqualToString:@"iPhone11,6"]) return @"iPhone XS Max";
    
    
    if ([hardware isEqualToString:@"iPod1,1"])      return @"iPod Touch (1 Gen)";
    if ([hardware isEqualToString:@"iPod2,1"])      return @"iPod Touch (2 Gen)";
    if ([hardware isEqualToString:@"iPod3,1"])      return @"iPod Touch (3 Gen)";
    if ([hardware isEqualToString:@"iPod4,1"])      return @"iPod Touch (4 Gen)";
    if ([hardware isEqualToString:@"iPod5,1"])      return @"iPod Touch (5 Gen)";
    if ([hardware isEqualToString:@"iPod7,1"])      return @"iPod Touch (6 Gen)";
    
    if ([hardware isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([hardware isEqualToString:@"iPad1,2"])      return @"iPad";
    if ([hardware isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([hardware isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([hardware isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([hardware isEqualToString:@"iPad2,4"])      return @"iPad 2";
    if ([hardware isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([hardware isEqualToString:@"iPad2,6"])      return @"iPad Mini (GSM)";
    if ([hardware isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([hardware isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([hardware isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([hardware isEqualToString:@"iPad3,3"])      return @"iPad 3 (GSM)";
    if ([hardware isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([hardware isEqualToString:@"iPad3,5"])      return @"iPad 4 (GSM)";
    if ([hardware isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([hardware isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([hardware isEqualToString:@"iPad4,2"])      return @"iPad Air (WiFi/Cellular)";
    if ([hardware isEqualToString:@"iPad4,3"])      return @"iPad Air (China)";
    if ([hardware isEqualToString:@"iPad4,4"])      return @"iPad Mini Retina (WiFi)";
    if ([hardware isEqualToString:@"iPad4,5"])      return @"iPad Mini Retina (WiFi/Cellular)";
    if ([hardware isEqualToString:@"iPad4,6"])      return @"iPad Mini Retina (China)";
    
    if ([hardware isEqualToString:@"iPad4,7"])      return @"iPad Mini 3 (WiFi)";
    if ([hardware isEqualToString:@"iPad4,8"])      return @"iPad Mini 3 (WiFi/Cellular)";
    if ([hardware isEqualToString:@"iPad5,1"])      return @"iPad Mini 4 (WiFi)";
    if ([hardware isEqualToString:@"iPad5,2"])      return @"iPad Mini 4 (WiFi/Cellular)";
    if ([hardware isEqualToString:@"iPad5,3"])      return @"iPad Air 2 (WiFi)";
    if ([hardware isEqualToString:@"iPad5,4"])      return @"iPad Air 2 (WiFi/Cellular)";
    if ([hardware isEqualToString:@"iPad6,3"])      return @"iPad Pro 9.7-inch (WiFi)";
    if ([hardware isEqualToString:@"iPad6,4"])      return @"iPad Pro 9.7-inch (WiFi/Cellular)";
    if ([hardware isEqualToString:@"iPad6,7"])      return @"iPad Pro 12.9-inch (WiFi)";
    if ([hardware isEqualToString:@"iPad6,8"])      return @"iPad Pro 12.9-inch (WiFi/Cellular)";
    if ([hardware isEqualToString:@"iPad6,11"])     return @"iPad 5 (WiFi)";
    if ([hardware isEqualToString:@"iPad6,12"])     return @"iPad 5 (WiFi/Cellular)";
    if ([hardware isEqualToString:@"iPad7,1"])      return @"iPad Pro 12.9-inch 2nd-gen (WiFi)";
    if ([hardware isEqualToString:@"iPad7,2"])      return @"iPad Pro 12.9-inch 2nd-gen (WiFi/Cellular)";
    if ([hardware isEqualToString:@"iPad7,3"])      return @"iPad Pro 10.5-inch (WiFi)";
    if ([hardware isEqualToString:@"iPad7,4"])      return @"iPad Pro 10.5-inch (WiFi/Cellular)";

  if ([hardware isEqualToString:@"i386"])         return @"Simulator";
  if ([hardware isEqualToString:@"x86_64"])       return @"Simulator";

  NSLog(@"Your device hardware string is: %@", hardware);

  if ([hardware hasPrefix:@"iPhone"]) return @"iPhone";
  if ([hardware hasPrefix:@"iPod"]) return @"iPod";
  if ([hardware hasPrefix:@"iPad"]) return @"iPad";

  return nil;
}


#pragma mark MAC addy
// Return the local MAC addy
// Courtesy of FreeBSD hackers email list
// Accidentally munged during previous update. Fixed thanks to mlamb.
- (NSString*)macaddress
{
    int mib[6];
    size_t len;
    char* buf;
    unsigned char* ptr;
    struct if_msghdr* ifm;
    struct sockaddr_dl* sdl;
    
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
        printf("Error: Memory allocation error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2\n");
        free(buf); // Thanks, Remy "Psy" Demerest
        return NULL;
    }
    
    ifm = (struct if_msghdr*)buf;
    sdl = (struct sockaddr_dl*)(ifm + 1);
    ptr = (unsigned char*)LLADDR(sdl);
    NSString* outstring = [NSString
                           stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X", *ptr, *(ptr + 1),
                           *(ptr + 2), *(ptr + 3), *(ptr + 4), *(ptr + 5)];
    
    free(buf);
    return outstring;
}


- (NSString *)devicetype
{
    return [[NSNumber numberWithInteger:TTDeviceType] stringValue];
}


- (NSString*)deviceSystemVersion
{
    return [[UIDevice currentDevice] systemVersion];
}

- (NSString*)deviceClientVersion
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

- (NSString*)deviceNettype
{
    MGReachability* reachability = [MGReachability reachabilityForInternetConnection];
    MGNetworkStatus currentStatus = reachability.currentReachabilityStatus;
    NSString* nettype = @"Unkown";
    switch (currentStatus) {
        case MGNotReachable:
            nettype = @"NotReachable";
            break;
        case MGReachableViaWiFi:
            nettype = @"WiFi";
            break;
        case MGReachableViaWWAN:
            nettype = @"2/3/4G";
            break;
        default:
            break;
    }
    
    return nettype;
}


-(NSString*)MGCarrierName
{
    CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netInfo subscriberCellularProvider];
    return [carrier carrierName];
}

- (NSString *) MGDeviceResolution
{
    CGSize size = [[UIScreen mainScreen] bounds].size;
    CGFloat scale = [UIScreen mainScreen].scale;
    size = CGSizeMake(size.width * scale, size.height *scale);
    return NSStringFromCGSize(size);
}

- (NSString *) MGDeviceIdfv
{
    NSString *idfv = @"";
    if (TT_IS_IOS6_AND_UP) {
        idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    }
    return idfv == nil ? @"": idfv;
}

- (NSDictionary *) deviceDict
{
    NSDictionary *params = nil;
    
    @try {
          
       
        NSString *carrierName = [[UIDevice currentDevice] MGCarrierName];
        NSString *macaddress = [[UIDevice currentDevice] macaddress];
        NSString *model = [[UIDevice currentDevice] hardwareSimpleDescription];
        NSString *app_ver = [[UIDevice currentDevice] deviceClientVersion];
        app_ver = app_ver == nil ? @"": app_ver;
        
        params = @{@"did":   [NSString IDFAORSimulateIDFA],
                   @"os":    [self deviceSystemVersion],
                   @"model": model?model:@"",
                   @"_model": model?model:@"",
                   @"nettype": [self deviceNettype],
                   @"sdk_ver": [MGManager sdkVersion],
                   @"app_ver": app_ver,
                   @"carrier": carrierName == nil ? @"": carrierName,
                   @"res": [self MGDeviceResolution],
                   @"macaddr": macaddress == nil ? @"" : macaddress,
                   @"useragent":[MGKeyChain mgKeyChainLoad:KEY_UA]
                   };
    }
    @catch (NSException *exception) {
        NSLog(@"get device environment error %@", exception);
    }
    @finally {
        return params;
    }
}



@end
