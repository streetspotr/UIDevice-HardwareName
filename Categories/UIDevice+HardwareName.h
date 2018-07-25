/*
 Based on:
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk

 Rewritten with lookup tables:
 Manfred Schwind, mani.de
 Streetspotr, streetspotr.com
*/

#import <UIKit/UIKit.h>

typedef enum {
    UIDeviceUnknown,
    
    UIDeviceSimulator,

    UIDevice1GiPhone,
    UIDevice3GiPhone,
    UIDevice3GSiPhone,
    UIDevice4iPhone,
    UIDevice4SiPhone,
    UIDevice5iPhone,
    UIDevice5CiPhone,
    UIDevice5SiPhone,
    UIDevice6iPhone,
    UIDevice6PlusiPhone,
	UIDevice6siPhone,
	UIDevice6sPlusiPhone,
	UIDeviceSEiPhone,
	UIDevice7iPhone,
	UIDevice7PlusiPhone,
	UIDevice8iPhone,
	UIDevice8PlusiPhone,
	UIDeviceXiPhone,

    UIDevice1GiPod,
    UIDevice2GiPod,
    UIDevice3GiPod,
    UIDevice4GiPod,
    UIDevice5GiPod,
	UIDevice6GiPod,

    UIDevice1GiPad,
    UIDevice2GiPad,
    UIDevice3GiPad,
	UIDevice6GiPad,

    UIDeviceiPadAir,
    UIDeviceiPadAir2,

    UIDevice1GiPadMini,
    UIDevice2GiPadMini,
    UIDevice3GiPadMini,

	UIDeviceiPadPro9,
	UIDeviceiPadPro10,
	UIDeviceiPadPro12,

    UIDeviceAppleTV2,
    UIDeviceAppleTV3,
    UIDeviceAppleTV4,
    
    UIDeviceUnknowniPhone,
    UIDeviceUnknowniPod,
    UIDeviceUnknowniPad,
    UIDeviceUnknownAppleTV

} UIDevicePlatform;

typedef enum {
    UIDeviceFamilyiPhone,
    UIDeviceFamilyiPod,
    UIDeviceFamilyiPad,
    UIDeviceFamilyAppleTV,
    UIDeviceFamilyUnknown
} UIDeviceFamily;

@interface PlatformInfo : NSObject

// convert the internal platform name (e.g. "iPhone8,1" into an PlatformInfo object (never nil):
+ (PlatformInfo *)createForPlatformIdentifier:(NSString *)identifier;

- (BOOL) haveInfo;						// do we have found any information at all?
- (BOOL) isExakt;						// is the platform exactly known or do we just have "unknown iPhone" or "unknown iPad" etc.?
- (NSString *) platformIdentifier;		// the internal name used for construction, e.g. "iPhone8,1"
- (UIDevicePlatform) platformType;		// own list lookup, e.g. UIDevice6sPlusiPhone
- (NSString *) platformString;			// human readable, e.g. "iPhone 6s Plus"
- (NSString *) verbosePlatformString;	// platformString with networkString, e.g. "iPhone 8 Plus (GSM)"
- (NSString *) networkString;			// e.g. "GSM", "CDMA", "WiFi" etc. but may be nil if unknown or unspecific
- (UIDeviceFamily) deviceFamily;

@end

@interface UIDevice (Hardware)
- (NSString *) platform;				// internal platform name, e.g. "iPhone8,1"
- (PlatformInfo *) platformInfo;		// more information about the platform (see PlatFormInfo above)
- (NSString *) hwmodel;

- (NSUInteger) cpuFrequency;
- (NSUInteger) busFrequency;
- (NSUInteger) cpuCount;
- (NSUInteger) totalMemory;
- (NSUInteger) userMemory;

- (NSNumber *) totalDiskSpace;
- (NSNumber *) freeDiskSpace;

- (NSString *) macaddress;

- (BOOL) hasRetinaDisplay;

@end

