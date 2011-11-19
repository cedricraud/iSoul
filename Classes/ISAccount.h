//
//  ISAccount.h
//  iSoul
//
//  Created by Cédric Raud on 23/03/09.
//  Copyright 2009 Epita. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSPMessages.h"
#import "Contact.h"
#import "ISMessage.h"
#import "UIDeviceHardware.h"

@interface ISAccount : NSObject {
	NSString *login;
	NSString *password;
	NSString *status;
	NSString *location;
	NSString *userdata;

	NSString *searching;
	NSMutableArray *contacts;
	NSMutableArray *talking;
	ImageLoader *imageLoader;
	Contact *searchContact;
	Contact *current;

	NSUserDefaults *_prefs;
}


// Enum
typedef enum status
{
	NETSOUL_STEP_CONNECTING,
	NETSOUL_STEP_CONNECTION_ESTABLISHED,
	NETSOUL_STEP_AUTH_AG_REQUEST,
	NETSOUL_STEP_AUTHENTICATION,
	NETSOUL_STEP_FAILURE,
	NETSOUL_STEP_HOST_FAIL
} e_status;


// Property
@property (nonatomic, retain) NSString *login;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) NSString *status;
@property (nonatomic, retain) NSString *location;
@property (nonatomic, retain) NSString *userdata;
@property (nonatomic, retain) NSString *searching;
@property (nonatomic, retain) NSMutableArray *contacts;
@property (nonatomic, retain) NSMutableArray *talking;
@property (nonatomic, retain) ImageLoader *imageLoader;
@property (nonatomic, retain) Contact *searchContact;
@property (nonatomic, retain) Contact *current;

// Methods
- (id)init;
- (void)didConnect;
- (void)didDisconnect;
- (void)connectionProgressStep:(e_status)step;
- (void)receiveMessage:(NSString *)message fromUser:(NSString *)user;
- (void)sendMessage:(NSString *)message toUser:(NSString *)user;
- (void)disconnectedFromServer;
- (void)contactIsNowOnline:(NSString *)user;
- (void)contactIsNowOffline:(NSString *)user;
- (void)contact:(NSString *)user changedState:(NSString *)state;
- (void)contactStartedTyping:(NSString *)user;
- (void)contactStoppedTyping:(NSString *)user;
- (void)receivedInfo:(NSArray *)content forUser:(NSString *)user;
- (Contact *)getContact:(NSString *)l;
- (Contact *)addContact:(NSString *)l;
- (void)save;
- (void)disconnect;

@end
