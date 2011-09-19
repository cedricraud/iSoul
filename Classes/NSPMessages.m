//
//  NSPMessages.m
//  NetSoulProtocol Messages - AdiumSoul
//
//  Created by Naixn on 11/04/08.
//  Copyright 2008 Epitech. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import "NSPMessages.h"
#import "NSPCUtilities.h"

@implementation NSPMessages

#pragma mark Authentication

+ (NSString *)askAuthentication
{
    return @"auth_ag ext_user none -";
}

+ (NSString *)authentication:(NSDictionary *)connectionValues
{
    return [NSPMessages standardAuthentication:connectionValues];
}


NSString*	md5( NSString *str )
{
	const char *cStr = [str UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5( cStr, strlen(cStr), result );
	return [[NSString  stringWithFormat:
			@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			result[0], result[1], result[2], result[3], result[4],
			result[5], result[6], result[7],
			result[8], result[9], result[10], result[11], result[12],
			result[13], result[14], result[15]
			] lowercaseString];
}


+ (NSString *)standardAuthentication:(NSDictionary *)connectionValues
{
    NSString*       hash_string;
//    NSData*         data;
    //char            hashMd5[32];
    NSString*		encoding;
    //int             i;

    hash_string = [NSString stringWithFormat:@"%@-%@/%@%@",
                   [connectionValues objectForKey:@"md5hash"],
                   [connectionValues objectForKey:@"clientIp"],
                   [connectionValues objectForKey:@"clientPort"],
                   [connectionValues objectForKey:@"password"]];
    //data = [hash_string dataUsingEncoding:[NSString defaultCStringEncoding]];

    encoding = md5(hash_string);
	/*
    memset(hashMd5, 0, 32);
    for (i = 0; i < 16; i++)
    {
        sprintf(hashMd5, "%s%02x", hashMd5, encoding[i]);
    }*/
    return [NSString stringWithFormat:@"ext_user_log %@ %@ %@ %@",
            [connectionValues objectForKey:@"login"],
            encoding,
            [NSPMessages encode:[connectionValues objectForKey:@"location"]],
            [NSPMessages encode:[connectionValues objectForKey:@"userData"]]
           ];
}

#pragma mark Messages

+ (NSString *)decode:(NSString *)aMsg
{
//    char*       msg;
//    char*       res;
//    NSString*   message;

//    msg = strdup([[(NSString*)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (CFStringRef)aMsg, CFSTR(""), kCFStringEncodingISOLatin1) autorelease] cStringUsingEncoding:NSISOLatin1StringEncoding]);
//    res = eval_carriage_returns(msg);
//    message = [NSString stringWithCString:res encoding:NSISOLatin1StringEncoding];
//    free(msg);
//    return message;
//    return [(NSString*)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (CFStringRef)aMsg, CFSTR(""), kCFStringEncodingISOLatin1) autorelease];
    return (NSString*)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (CFStringRef)aMsg, CFSTR(""), kCFStringEncodingISOLatin1);
}

+ (NSString *)encode:(NSString *)aMsg
{
//	    return [(NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)aMsg, NULL, (CFStringRef)@"!@#$%^&*()_+=-{[]};:?/.,~", kCFStringEncodingISOLatin1) autorelease];
    return (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)aMsg, NULL, (CFStringRef)@"!@#$%^&*()_+=-{[]};:?/.,~", kCFStringEncodingISOLatin1);
}

+ (NSString *)sendMessage:(NSString *)message toUser:(NSString *)user
{
    NSString*   encodedMsg = [NSPMessages encode:message];

    if (!encodedMsg)
    {
        return nil;
    }
    return [NSString stringWithFormat:@"user_cmd msg_user %@ msg %@", user, encodedMsg];
}

+ (NSString *)startWritingToUser:(NSString *)user
{
    return [NSString stringWithFormat:@"user_cmd msg_user %@ dotnetSoul_UserTyping null", user];
}

+ (NSString *)stopWritingToUser:(NSString *)user
{
    return [NSString stringWithFormat:@"user_cmd msg_user %@ dotnetSoul_UserCancelledTyping null", user];
}

#pragma mark User-related stuff

+ (NSString *)userListFromArray:(NSArray *)users
{
    if ([users count] == 0)
    {
        return (nil);
    }
    return [users componentsJoinedByString:@","];
}

+ (NSString *)listUsers:(NSArray *)users
{
    NSString*   userList = [NSPMessages userListFromArray:users];

    if (userList == nil)
    {
        return nil;
    }
    return [NSString stringWithFormat:@"list_users {%@}", userList];
}

+ (NSString *)whoUsers:(NSArray *)users
{
    NSString*   userList = [NSPMessages userListFromArray:users];

    if (userList == nil)
    {
        return nil;
    }
    return [NSString stringWithFormat:@"user_cmd who {%@}", userList];
}

+ (NSString *)setState:(NSString *)state
{
    return [NSString stringWithFormat:@"user_cmd state %@:%i", state, time(0)];
}

+ (NSString *)watchUsers:(NSArray *)users
{
    NSString*   userList = [NSPMessages userListFromArray:users];

    if (userList == nil)
        return nil;
    return [NSString stringWithFormat:@"user_cmd watch_log_user {%@}", userList];
}

+ (NSString *)who:(NSString *)user
{
    return [NSString stringWithFormat:@"user_cmd who %@", user];
}

#pragma mark Other stuff

+ (NSString *)exit
{
    return @"exit";
}

+ (NSString *)ping
{
    return @"ping";
}

+ (NSString *)setUserData:(NSString *)data
{
    return [NSString stringWithFormat: @"user_cmd user_data %@", [NSPMessages encode:data]];
}

@end

