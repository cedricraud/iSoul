//
//  UIDeviceHardware.m
//  iSoul
//
//  Created by Cédric Raud on 21/07/09.
//  Copyright 2009 Epita. All rights reserved.
//

#import "UIDeviceHardware.h"
#include <sys/types.h>
#include <sys/sysctl.h>

@implementation UIDevice (Hardware)

- (NSString *) platform
{
	size_t size;
	sysctlbyname("hw.machine", NULL, &size, NULL, 0);
	char *machine = malloc(size);
	sysctlbyname("hw.machine", machine, &size, NULL, 0);
	NSString *platform = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
	free(machine);
	return platform;
}

- (NSString *) platformString
{
	NSString *platform = [self platform];
	if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone";
	if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
	if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
  	if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4";
	if ([platform isEqualToString:@"iPod1,1"])   return @"iPod";
	if ([platform isEqualToString:@"iPod2,1"])   return @"iPod 2G";
	if ([platform isEqualToString:@"iPod3,1"])   return @"iPod 3G";
	return @"iPhone";
}
@end