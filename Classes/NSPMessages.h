//
//  NSPMessages.h
//  NetSoulProtocol Messages - AdiumSoul
//
//  Created by Naixn on 11/04/08.
//  Copyright 2008 Epitech. All rights reserved.
//


@interface NSPMessages : NSObject
{}

#pragma mark Authentication
+ (NSString *)askAuthentication;
+ (NSString *)authentication:(NSDictionary *)connectionValues;
+ (NSString *)standardAuthentication:(NSDictionary *)connectionValues;

#pragma mark Messages
+ (NSString *)decode:(NSString *)aMsg;
+ (NSString *)encode:(NSString *)aMsg;
+ (NSString *)sendMessage:(NSString *)message toUser:(NSString *)user;
+ (NSString *)startWritingToUser:(NSString *)user;
+ (NSString *)stopWritingToUser:(NSString *)user;

#pragma mark User-related stuff
+ (NSString *)userListFromArray:(NSArray *)users;
+ (NSString *)listUsers:(NSArray *)users;
+ (NSString *)whoUsers:(NSArray *)users;
+ (NSString *)setState:(NSString *)state;
+ (NSString *)watchUsers:(NSArray *)users;
+ (NSString *)who:(NSString *)user;

#pragma mark Other stuff
+ (NSString *)exit;
+ (NSString *)ping;
+ (NSString *)setUserData:(NSString *)data;

@end
