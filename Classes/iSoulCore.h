//
//  iSoulCore.h
//  NetSoulProtocol - iSoul
//
//  Created by Naixn on 09/04/08.
//  Modified by spycAm on 03/21/09.
//

#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <fcntl.h>
#include <unistd.h>

#import "NSPMessages.h"
#import "ISAccount.h"

@interface iSoulCore : NSObject
{
   NSFileHandle *connection;
   BOOL authenticated;
   NSString *lastMessage;
   NSMutableArray *replyDataPool;
	ISAccount *_account;
}

// Init and connexion
- (id)initWithISAccount:(ISAccount *) a;
- (void)threadConnect:(id)mainThreadOject;
- (void)failedToConnect;
- (void)didConnectWithFd:(id)fdNumber;
- (void)connect;
- (BOOL)disconnect;
- (BOOL)isAuthenticated;

// Socket relative function
- (void)receiveMessageFromSocket:(NSNotification *)notification;
- (void)sendMessageToSocket:(NSString *)message appendNewLine:(BOOL)appendNewLine;

// User-side actions
- (BOOL)sendMessage:(NSString *)message toUser:(NSString *)user;
- (void)sendTypingEvent:(bool)state toUser:(NSString *)user;
- (void)watchUser:(NSString *)user;
- (void)watchUsers:(NSArray *)user;
- (void)whoUser:(NSString *)user;
- (void)whoUsers:(NSArray *)users;

// Handling commands
+ (SEL)selectorForCommand:(NSString *)command;
- (void)userCommand:(NSString *)message;
- (void)firstReply:(NSString *)message;
- (void)authenticate:(NSMutableDictionary *)authenticationValues;
- (void)authenticationFailed;
- (void)ready;
- (void)ping;
//// Events
- (void)recvMessage:(NSDictionary *)message;
- (void)recvLogin:(NSDictionary *)data;
- (void)recvLogout:(NSDictionary *)data;
- (void)recvChangeStatus:(NSDictionary *)data;
- (void)recvStartTyping:(NSDictionary *)data;
- (void)recvStopTyping:(NSDictionary *)data;
- (void)recvUserInfo:(NSDictionary *)data;

// Handling replies
- (void)waitReplyToSendMessage:(NSString *)message withObject:(id)object orErrorMessage:(NSString *)error;
- (void)waitReplyToSendMessage:(NSString *)message withObject:(id)object;
- (void)handleReply:(NSString *)message;

@end
