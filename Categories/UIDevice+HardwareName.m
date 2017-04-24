/*
 Based on:
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk

 Rewritten with lookup tables:
 Manfred Schwind, mani.de
 Streetspotr, streetspotr.com
 */

// Thanks to Emanuele Vulcano, Kevin Ballard/Eridius, Ryandjohnson, Matt Brown, etc.

#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

#import "UIDevice+HardwareName.h"

typedef struct {
	const char *identifier;
	UIDevicePlatform platform;
	UIDeviceFamily family;
	const char *platformName;
} Platform;

static NSString * const unknownPlatformName = @"Unknown Device";

// lookup tables:

static const Platform knownPlatforms[] = {
	{"iPhone1,1", UIDevice1GiPhone, UIDeviceFamilyiPhone, "iPhone 1G"},
	{"iPhone1,2", UIDevice3GiPhone, UIDeviceFamilyiPhone, "iPhone 3G"},
	{"iPhone2,1", UIDevice3GSiPhone, UIDeviceFamilyiPhone, "iPhone 3GS"},
	{"iPhone3,1", UIDevice4iPhone, UIDeviceFamilyiPhone, "iPhone 4 (AT&T)"},
	{"iPhone3,2", UIDevice4iPhone, UIDeviceFamilyiPhone, "iPhone 4"},
	{"iPhone3,3", UIDevice4iPhone, UIDeviceFamilyiPhone, "iPhone 4 (Verizon)"},
	{"iPhone4,1", UIDevice4SiPhone, UIDeviceFamilyiPhone, "iPhone 4S (GSM)"},
	{"iPhone4,2", UIDevice4SiPhone, UIDeviceFamilyiPhone, "iPhone 4S (CDMA)"},
	{"iPhone4,3", UIDevice4SiPhone, UIDeviceFamilyiPhone, "iPhone 4S"},
	{"iPhone5,1", UIDevice5iPhone, UIDeviceFamilyiPhone, "iPhone 5"},
	{"iPhone5,2", UIDevice5iPhone, UIDeviceFamilyiPhone, "iPhone 5"},
	{"iPhone5,3", UIDevice5CiPhone, UIDeviceFamilyiPhone, "iPhone 5c"},
	{"iPhone5,4", UIDevice5CiPhone, UIDeviceFamilyiPhone, "iPhone 5c"},
	{"iPhone6,1", UIDevice5SiPhone, UIDeviceFamilyiPhone, "iPhone 5s"},
	{"iPhone6,2", UIDevice5SiPhone, UIDeviceFamilyiPhone, "iPhone 5s"},
	{"iPhone7,1", UIDevice6PlusiPhone, UIDeviceFamilyiPhone, "iPhone 6 Plus"},
	{"iPhone7,2", UIDevice6iPhone, UIDeviceFamilyiPhone, "iPhone 6"},
	{"iPhone8,1", UIDevice6siPhone, UIDeviceFamilyiPhone, "iPhone 6s"},
	{"iPhone8,2", UIDevice6sPlusiPhone, UIDeviceFamilyiPhone, "iPhone 6s Plus"},
	{"iPhone8,3", UIDeviceSEiPhone, UIDeviceFamilyiPhone, "iPhone SE (CDMA)"},
	{"iPhone8,4", UIDeviceSEiPhone, UIDeviceFamilyiPhone, "iPhone SE (GSM)"},
	{"iPhone9,1", UIDevice7iPhone, UIDeviceFamilyiPhone, "iPhone 7"},
	{"iPhone9,2", UIDevice7PlusiPhone, UIDeviceFamilyiPhone, "iPhone 7 Plus"},
	{"iPhone9,3", UIDevice7iPhone, UIDeviceFamilyiPhone, "iPhone 7"},
	{"iPhone9,4", UIDevice7PlusiPhone, UIDeviceFamilyiPhone, "iPhone 7 Plus"},

	{"iPod1,1", UIDevice1GiPod, UIDeviceFamilyiPod, "iPod touch 1G"},
	{"iPod2,1", UIDevice2GiPod, UIDeviceFamilyiPod, "iPod touch 2G"},
	{"iPod3,1", UIDevice3GiPod, UIDeviceFamilyiPod, "iPod touch 3G"},
	{"iPod4,1", UIDevice4GiPod, UIDeviceFamilyiPod, "iPod touch 4G"},
	{"iPod5,1", UIDevice5GiPod, UIDeviceFamilyiPod, "iPod touch 5G"},
	{"iPod7,1", UIDevice6GiPod, UIDeviceFamilyiPod, "iPod touch 6G"},

	{"iPad1,1", UIDevice1GiPad, UIDeviceFamilyiPad, "iPad 1G"},
	{"iPad2,1", UIDevice2GiPad, UIDeviceFamilyiPad, "iPad 2G (WiFi)"},
	{"iPad2,2", UIDevice2GiPad, UIDeviceFamilyiPad, "iPad 2G (GSM)"},
	{"iPad2,3", UIDevice2GiPad, UIDeviceFamilyiPad, "iPad 2G (CDMA)"},
	{"iPad2,4", UIDevice2GiPad, UIDeviceFamilyiPad, "iPad 2G"},
	{"iPad3,1", UIDevice3GiPad, UIDeviceFamilyiPad, "iPad 3G (WiFi)"},
	{"iPad3,2", UIDevice3GiPad, UIDeviceFamilyiPad, "iPad 3G (GSM)"},
	{"iPad3,3", UIDevice3GiPad, UIDeviceFamilyiPad, "iPad 3G (CDMA)"},
	{"iPad3,4", UIDevice3GiPad, UIDeviceFamilyiPad, "iPad 3G"},
	{"iPad3,5", UIDevice3GiPad, UIDeviceFamilyiPad, "iPad 3G"},
	{"iPad3,6", UIDevice3GiPad, UIDeviceFamilyiPad, "iPad 3G"},

	{"iPad4,1", UIDeviceiPadAir, UIDeviceFamilyiPad, "iPad Air (WiFi)"},
	{"iPad4,2", UIDeviceiPadAir, UIDeviceFamilyiPad, "iPad Air (GSM)"},
	{"iPad4,3", UIDeviceiPadAir, UIDeviceFamilyiPad, "iPad Air (CDMA)"},
	{"iPad5,3", UIDeviceiPadAir2, UIDeviceFamilyiPad, "iPad Air 2"},
	{"iPad5,4", UIDeviceiPadAir2, UIDeviceFamilyiPad, "iPad Air 2"},

	{"iPad2,5", UIDevice1GiPadMini, UIDeviceFamilyiPad, "iPad Mini 1G"},
	{"iPad2,6", UIDevice1GiPadMini, UIDeviceFamilyiPad, "iPad Mini 1G"},
	{"iPad2,7", UIDevice1GiPadMini, UIDeviceFamilyiPad, "iPad Mini 1G"},
	{"iPad4,4", UIDevice2GiPadMini, UIDeviceFamilyiPad, "iPad Mini 2G"},
	{"iPad4,5", UIDevice2GiPadMini, UIDeviceFamilyiPad, "iPad Mini 2G"},
	{"iPad4,6", UIDevice2GiPadMini, UIDeviceFamilyiPad, "iPad Mini 2G"},
	{"iPad4,7", UIDevice3GiPadMini, UIDeviceFamilyiPad, "iPad Mini 3G"},
	{"iPad4,8", UIDevice3GiPadMini, UIDeviceFamilyiPad, "iPad Mini 3G"},
	{"iPad4,9", UIDevice3GiPadMini, UIDeviceFamilyiPad, "iPad Mini 3G"},

    {"iPad6,3", UIDeviceiPadPro9, UIDeviceFamilyiPad, "iPad Pro (9.7\", WiFi)"},
    {"iPad6,4", UIDeviceiPadPro9, UIDeviceFamilyiPad, "iPad Pro (9.7\", LTE)"},
    {"iPad6,7", UIDeviceiPadPro12, UIDeviceFamilyiPad, "iPad Pro (12.9\", WiFi)"},
    {"iPad6,8", UIDeviceiPadPro12, UIDeviceFamilyiPad, "iPad Pro (12.9\", LTE)"},

	{"AppleTV2,1", UIDeviceAppleTV2, UIDeviceFamilyAppleTV, "Apple TV 2"},
	{"AppleTV3,1", UIDeviceAppleTV3, UIDeviceFamilyAppleTV, "Apple TV 3"},
	{"AppleTV3,2", UIDeviceAppleTV4, UIDeviceFamilyAppleTV, "Apple TV 4"}
};

static const Platform unknownPlatforms[] = {
	{"iPhone", UIDeviceUnknowniPhone, UIDeviceFamilyiPhone, "Unknown iPhone"},
	{"iPod", UIDeviceUnknowniPod, UIDeviceFamilyiPod, "Unknown iPod"},
	{"iPad", UIDeviceUnknowniPad, UIDeviceFamilyiPad, "Unknown iPad", },
	{"AppleTV", UIDeviceUnknownAppleTV, UIDeviceFamilyAppleTV, "Unknown Apple TV", }
};


@implementation UIDevice (Hardware)

#pragma mark sysctlbyname utils
- (NSString *) getSysInfoByName:(char *)typeSpecifier
{
    size_t size;
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
    
    char *answer = malloc(size);
    sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
    
    NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];

    free(answer);
    return results;
}

- (NSString *) platform
{
    return [self getSysInfoByName:"hw.machine"];
}

// Thanks, Tom Harrington (Atomicbird)
- (NSString *) hwmodel
{
    return [self getSysInfoByName:"hw.model"];
}

#pragma mark sysctl utils
- (NSUInteger) getSysInfo: (uint) typeSpecifier
{
    size_t size = sizeof(int);
    int results;
    int mib[2] = {CTL_HW, typeSpecifier};
    sysctl(mib, 2, &results, &size, NULL, 0);
    return (NSUInteger) results;
}

- (NSUInteger) cpuFrequency
{
    return [self getSysInfo:HW_CPU_FREQ];
}

- (NSUInteger) busFrequency
{
    return [self getSysInfo:HW_BUS_FREQ];
}

- (NSUInteger) cpuCount
{
    return [self getSysInfo:HW_NCPU];
}

- (NSUInteger) totalMemory
{
    return [self getSysInfo:HW_PHYSMEM];
}

- (NSUInteger) userMemory
{
    return [self getSysInfo:HW_USERMEM];
}

- (NSUInteger) maxSocketBufferSize
{
    return [self getSysInfo:KIPC_MAXSOCKBUF];
}

#pragma mark file system -- Thanks Joachim Bean!

- (NSNumber *) totalDiskSpace
{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return [fattributes objectForKey:NSFileSystemSize];
}

- (NSNumber *) freeDiskSpace
{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return [fattributes objectForKey:NSFileSystemFreeSize];
}

#pragma mark platform type and name utils

- (UIDevicePlatform) platformType
{
    return [UIDevice platform2type:[self platform]];
}

// private
+ (UIDevicePlatform) platform2type: (NSString *)platform
{
	@autoreleasepool {
		for(int i = 0; i < (int)(sizeof(knownPlatforms) / sizeof(Platform)); ++i) {
			const Platform *known = &knownPlatforms[i];
			if ([platform isEqualToString:[NSString stringWithUTF8String:known->identifier]]) {
				return known->platform;
			}
		}
	}
	@autoreleasepool {
		for(int i = 0; i < (int)(sizeof(unknownPlatforms) / sizeof(Platform)); ++i) {
			const Platform *unknown = &unknownPlatforms[i];
			if ([platform hasPrefix:[NSString stringWithUTF8String:unknown->identifier]]) {
				return unknown->platform;
			}
		}
	}
    if ([platform hasSuffix:@"86"] || [platform isEqual:@"x86_64"]) {
        return UIDeviceSimulator;
    }
	return UIDeviceUnknown;
}

- (NSString *) platformString
{
    return [UIDevice platform2string:[self platform]];
}

// private
+ (NSString *) platform2string: (NSString *)platform
{
    @autoreleasepool {
        for(int i = 0; i < (int)(sizeof(knownPlatforms) / sizeof(Platform)); ++i) {
            const Platform *known = &knownPlatforms[i];
            if ([platform isEqualToString:[NSString stringWithUTF8String:known->identifier]]) {
                return [NSString stringWithUTF8String:known->platformName];
            }
        }
    }
    @autoreleasepool {
        for(int i = 0; i < (int)(sizeof(unknownPlatforms) / sizeof(Platform)); ++i) {
            const Platform *unknown = &unknownPlatforms[i];
            if ([platform hasPrefix:[NSString stringWithUTF8String:unknown->identifier]]) {
                return [NSString stringWithUTF8String:unknown->platformName];
            }
        }
    }
    return unknownPlatformName;
}

- (UIDeviceFamily) deviceFamily
{
	return [UIDevice platform2family:[self platform]];
}

// private
+ (UIDeviceFamily) platform2family: (NSString *)platform
{
	@autoreleasepool {
		for(int i = 0; i < (int)(sizeof(knownPlatforms) / sizeof(Platform)); ++i) {
			const Platform *known = &knownPlatforms[i];
			if ([platform isEqualToString:[NSString stringWithUTF8String:known->identifier]]) {
				return known->family;
			}
		}
	}
	@autoreleasepool {
		for(int i = 0; i < (int)(sizeof(unknownPlatforms) / sizeof(Platform)); ++i) {
			const Platform *unknown = &unknownPlatforms[i];
			if ([platform hasPrefix:[NSString stringWithUTF8String:unknown->identifier]]) {
				return unknown->family;
			}
		}
	}
	return UIDeviceFamilyUnknown;
}

- (BOOL) hasRetinaDisplay
{
    return ([UIScreen mainScreen].scale == 2.0f);
}

#pragma mark MAC addy
// Return the local MAC addy
// Courtesy of FreeBSD hackers email list
// Accidentally munged during previous update. Fixed thanks to mlamb.
- (NSString *) macaddress
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
		assert(false);	// Error: if_nametoindex error
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
		assert(false);	// Error: sysctl, take 1
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
		assert(false);	// Error: Out of memory!
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
		assert(false);	// Error: sysctl, take 2
        free(buf);		// Thanks, Remy "Psy" Demerest
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];

    free(buf);
    return outstring;
}

// Illicit Bluetooth check -- cannot be used in App Store
/* 
Class  btclass = NSClassFromString(@"GKBluetoothSupport");
if ([btclass respondsToSelector:@selector(bluetoothStatus)])
{
    printf("BTStatus %d\n", ((int)[btclass performSelector:@selector(bluetoothStatus)] & 1) != 0);
    bluetooth = ((int)[btclass performSelector:@selector(bluetoothStatus)] & 1) != 0;
    printf("Bluetooth %s enabled\n", bluetooth ? "is" : "isn't");
}
*/
@end
