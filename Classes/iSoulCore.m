//
//  iSoulCore.m
//  NetSoulProtocol - iSoul
//
//  Created by Naixn on 09/04/08.
//  Modified by spycAm on 03/21/09.
//

#import "iSoulCore.h"

static NSMutableDictionary *gl_functions = nil;

@implementation iSoulCore

- (id)initWithISAccount:(ISAccount *) a;
{
    if (self = [super init])
    {
        connection     = nil;
        authenticated  = NO;
        lastMessage    = nil;
        replyDataPool  = nil;
		_account = a;

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connect:) name:@"ISC/connect" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disconnect:) name:@"ISC/disconnect" object:nil];

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendMessage:) name:@"ISC/sendMessage" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(watchUserN:) name:@"ISC/watchUser" object:nil];

    }
    return self;
}

- (void) dealloc
{
    [super dealloc];
}

- (void)threadConnect:(id)mainThreadOject
{
    // NSData *address;
    // NSSocketPort *sock;
	struct sockaddr_in stSockAddr;
    int             s;
    int             cs;
	struct hostent *host;

    // Dirty hack to wake up cellular network (sockets don't)
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	[NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://hxt.fr/isoul/void"] encoding: NSASCIIStringEncoding  error: nil];
	[pool release];

    //sock = [[NSSocketPort alloc] initRemoteWithTCPPort:4242	host:@"ns-server.epita.fr"];
	memset(&stSockAddr, 0, sizeof(stSockAddr));

    stSockAddr.sin_family = AF_INET;
    stSockAddr.sin_port = htons(4242);
	host = gethostbyname("ns-server.epita.fr");


    if (host == NULL)
    {
		NSLog(@"host fail");
		[_account connectionProgressStep:NETSOUL_STEP_HOST_FAIL];
        [mainThreadOject performSelectorOnMainThread:@selector(failedToConnect) withObject:nil waitUntilDone:NO];
        [NSThread exit];
    }
	stSockAddr.sin_addr.s_addr = ((struct in_addr *)*host->h_addr_list)->s_addr;

    s = socket(AF_INET, SOCK_STREAM, 0);
    if (s < 0)
    {
		NSLog(@"socket fail");
        //[sock release];
		[_account connectionProgressStep:NETSOUL_STEP_HOST_FAIL];
        [mainThreadOject performSelectorOnMainThread:@selector(failedToConnect) withObject:nil waitUntilDone:NO];
        [NSThread exit];
    }
    //address = [sock address];
    cs = connect(s, (struct sockaddr *) &stSockAddr, sizeof(stSockAddr));
    if (cs < 0)
    {
		NSLog(@"connect fail");
        //[sock release];
        close(s);
		[_account connectionProgressStep:NETSOUL_STEP_HOST_FAIL];
        [mainThreadOject performSelectorOnMainThread:@selector(failedToConnect) withObject:nil waitUntilDone:NO];
        [NSThread exit];
    }
    //[sock release];

    [mainThreadOject performSelectorOnMainThread:@selector(didConnectWithFd:) withObject:[[NSNumber alloc] initWithInt:s] waitUntilDone:NO];

    [NSThread exit];
}

- (void)failedToConnect
{
    NSLog(@"[AdiumSoul] Could not connect... Maybe server is offline?");
	[_account didDisconnect];

}

- (void)didConnectWithFd:(id)fdNumber
{
    int fd = [fdNumber intValue];

    [fdNumber release];
	[_account connectionProgressStep:NETSOUL_STEP_CONNECTION_ESTABLISHED];


    connection = [[NSFileHandle alloc] initWithFileDescriptor:fd closeOnDealloc:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveMessageFromSocket:)
                                                 name:NSFileHandleReadCompletionNotification
                                               object:connection];
    [connection readInBackgroundAndNotify];
    //[connection readInBackgroundAndNotifyForModes:[NSArray arrayWithObjects: NSEventTrackingRunLoopMode, NSModalPanelRunLoopMode, NSDefaultRunLoopMode, nil]];

    replyDataPool = [[NSMutableArray alloc] init];
}

- (void)connect
{
    [NSThread detachNewThreadSelector:@selector(threadConnect:) toTarget:self withObject:self];
}

- (void)connect:(NSNotification *)notification
{
	[self connect];
}


- (BOOL)disconnect
{
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
    if (connection)
    {
        [connection closeFile];
        [connection release];
        connection = nil;
    }
	[_account didDisconnect];
    [replyDataPool release];
    replyDataPool = nil;
    authenticated = NO;

    NSLog(@"[AdiumSoul] Disconnecting");
    return YES;
}

- (void)disconnect:(NSNotification *)notification
{
	[self disconnect];
}

- (BOOL)isAuthenticated
{
    return authenticated;
}

#pragma mark -
#pragma mark Socket relative methods

- (void)receiveMessageFromSocket:(NSNotification *)notification
{
    NSData *messageData;
    NSString *message;
    NSString *tempMessage;
    NSString *command;
    NSMutableArray *array;
    SEL             selector;

    messageData = [[notification userInfo] objectForKey:NSFileHandleNotificationDataItem];
    // If there was nothing to read, it means the server disconnecter
    if ([messageData length] == 0)
    {
        NSLog(@"Server closed the connection");
		[_account disconnectedFromServer];
        //[self disconnect];
        return ;
    }

    // Get data string, and append to last time we got something
    tempMessage = [[NSString alloc] initWithData:messageData encoding:NSUTF8StringEncoding];
    if (lastMessage)
    {
        message = [lastMessage stringByAppendingString:tempMessage];
        [lastMessage release];
        lastMessage = nil;
    }
    else
    {
        message = [NSString stringWithString:tempMessage];
    }
    [tempMessage release];

    array = [[message componentsSeparatedByString:@"\n"] mutableCopy];
    // If the last component of the array has length >0, it means it didn't end with a \n. We need to keep it for later use.
    if ([[array lastObject] length])
    {
        lastMessage = [[array lastObject] retain];
    }
    [array removeLastObject];

    NSEnumerator *enumerator = [array objectEnumerator];
    NSString *line;
    while ((line = [enumerator nextObject]))
    {
        NSLog(@"[AdiumSoul] Received line '%@'", line);
        command = [[line componentsSeparatedByString:@" "] objectAtIndex:0];
        selector = [iSoulCore selectorForCommand:command];
        if (selector != (SEL)0)
        {
            [self performSelector:[iSoulCore selectorForCommand:command]
                       withObject:[line substringFromIndex:([command length] + 1)]];
        }
        else
        {
            // if not regognized, let's assume it's a list_users reply
        }
    }
    [array release];

    [connection readInBackgroundAndNotify];
    //[connection readInBackgroundAndNotifyForModes:[NSArray arrayWithObjects: NSEventTrackingRunLoopMode, NSModalPanelRunLoopMode, NSDefaultRunLoopMode, nil]];
}

- (void)sendMessageToSocket:(NSString *)message appendNewLine:(BOOL)appendNewLine
{
    NSLog(@"[AdiumSoul] Writing to socket: '%@'", message);
    if (appendNewLine)
    {
        message = [message stringByAppendingString:@"\n"];
    }
    NSData *messageData = [NSData dataWithBytes:[message UTF8String] length:[message length]];
    [connection writeData:messageData];
}

#pragma mark -
#pragma mark User-side actions

- (BOOL)sendMessage:(NSString *)message toUser:(NSString *)user
{
    NSString *encodedMessage = [NSPMessages sendMessage:message toUser:user];

    if (!encodedMessage)
    {
        return NO;
    }
    [self sendMessageToSocket:encodedMessage appendNewLine:YES];
    return YES;
}

- (void)sendMessage:(NSNotification *)notification
{
	NSString *message = [[notification userInfo] objectForKey:@"message"];
	NSString *user = [[notification userInfo] objectForKey:@"user"];
	[self sendMessage:message toUser:user];
}

- (void)sendTypingEvent:(bool)state toUser:(NSString *)user
{
    if (state)
    {
        [self sendMessageToSocket:[NSPMessages startWritingToUser:user] appendNewLine:YES];
    }
    else
    {
        [self sendMessageToSocket:[NSPMessages stopWritingToUser:user] appendNewLine:YES];
    }
}

- (void)watchUser:(NSString *)user
{
    [self watchUsers:[NSArray arrayWithObject:user]];
}

- (void)watchUserN:(NSNotification *)notification
{
	NSString *user = [[notification userInfo] objectForKey:@"user"];
	[self watchUser:user];
	[self whoUser:user];
}


- (void)watchUsers:(NSArray *)users
{
    if (users && [users count] > 0)
    {
        [self sendMessageToSocket:[NSPMessages watchUsers:users] appendNewLine:YES];
    }
}

- (void)whoUser:(NSString *)user
{
    [self whoUsers:[NSArray arrayWithObject:user]];
}

- (void)whoUsers:(NSArray *)users
{
    if (users && [users count] > 0)
    {
        [self sendMessageToSocket:[NSPMessages whoUsers:users] appendNewLine:YES];
    }
}

#pragma mark -
#pragma mark Handling commands

+ (SEL)selectorForCommand:(NSString *)command
{
    if (gl_functions == nil)
    {
        gl_functions = [[NSMutableDictionary alloc] init];
        [gl_functions setObject:@"firstReply:"          forKey:@"salut"];
        [gl_functions setObject:@"ping"                 forKey:@"ping"];
        [gl_functions setObject:@"handleReply:"         forKey:@"rep"];
        [gl_functions setObject:@"userCommand:"         forKey:@"user_cmd"];
        [gl_functions setObject:@"recvMessage:"         forKey:@"msg"];
        [gl_functions setObject:@"recvUserInfo:"        forKey:@"who"];
        [gl_functions setObject:@"recvLogin:"           forKey:@"login"];
        [gl_functions setObject:@"recvLogout:"          forKey:@"logout"];
        [gl_functions setObject:@"recvStartTyping:"     forKey:@"typing_start"];
        [gl_functions setObject:@"recvStartTyping:"     forKey:@"dotnetSoul_UserTyping"];
        [gl_functions setObject:@"recvStopTyping:"      forKey:@"typing_end"];
        [gl_functions setObject:@"recvStopTyping:"      forKey:@"dotnetSoul_UserCancelledTyping"];
        [gl_functions setObject:@"recvChangeStatus:"    forKey:@"state"];
        [gl_functions setObject:@"ping"                 forKey:@"new_mail"];
    }
    return NSSelectorFromString([gl_functions objectForKey:command]);
}

- (void)userCommand:(NSString *)message
{
    NSArray *arr = [message componentsSeparatedByString:@" | "];
    NSArray *firstPart = [[arr objectAtIndex:0] componentsSeparatedByString:@":"];
    NSArray *secondPart = [[arr objectAtIndex:1] componentsSeparatedByString:@" "];
    NSString *socketId = [firstPart objectAtIndex:0];
    NSString *login = [firstPart objectAtIndex:3];
    NSString *command = [secondPart objectAtIndex:0];
    SEL         selector;

    NSRange range = [login rangeOfString:@"@"];
    login = [login substringToIndex:range.location];

	NSLog(@"received command : %@", command);
    selector = [iSoulCore selectorForCommand:command];
    if (selector != (SEL)0)
    {
        [self performSelector:selector withObject:[NSDictionary dictionaryWithObjectsAndKeys:login, @"login", socketId, @"socketId", secondPart, @"content", nil]];
    }
}

- (void)firstReply:(NSString *)message
{
    NSArray *arr;
    NSMutableDictionary *authenticationValues;

    arr = [message componentsSeparatedByString:@" "];
    /*
    * When connecting, we reveive multiple values :
    *  0 - connection socket id
    *  1 - random MD5 hash
    *  2 - client_ip
    *  3 - client port
    *  4 - timestamp from server
    */
    authenticationValues = [NSMutableDictionary dictionary];
    [authenticationValues setObject:[arr objectAtIndex:0] forKey:@"socket"];
    [authenticationValues setObject:[arr objectAtIndex:1] forKey:@"md5hash"];
    [authenticationValues setObject:[arr objectAtIndex:2] forKey:@"clientIp"];
    [authenticationValues setObject:[arr objectAtIndex:3] forKey:@"clientPort"];
    [authenticationValues setObject:[arr objectAtIndex:4] forKey:@"timestamp"];
    [_account connectionProgressStep:NETSOUL_STEP_AUTH_AG_REQUEST];

    [self waitReplyToSendMessage:@"authenticate:" withObject:authenticationValues];
    [self sendMessageToSocket:[NSPMessages askAuthentication] appendNewLine:YES];
}

- (void)authenticate:(NSMutableDictionary *)authenticationValues
{
	NSLog(@"pwd : %@", [_account password]);
    [authenticationValues setObject:[_account login] forKey:@"login"];
    [authenticationValues setObject:[_account password] forKey:@"password"];
    [authenticationValues setObject:[_account location] forKey:@"location"];
    [authenticationValues setObject:[NSString stringWithFormat:@"iSoul [ %@ ]", [_account userdata]] forKey:@"userData"];
    [_account connectionProgressStep:NETSOUL_STEP_AUTHENTICATION];
    [self waitReplyToSendMessage:@"ready" withObject:nil orErrorMessage:@"authenticationFailed"];
    [self sendMessageToSocket:[NSPMessages authentication:authenticationValues]
                appendNewLine:YES];
    [authenticationValues release];
}

- (void)authenticationFailed
{
	[_account connectionProgressStep:NETSOUL_STEP_FAILURE];
    NSLog(@"[AdiumSoul] Authentication failed");
    [self disconnect];
}

- (void)ready
{
    [_account didConnect];
    [self sendMessageToSocket:[NSPMessages setState:[_account status]]
                appendNewLine:YES];
    authenticated = YES;

	for (Contact *c in _account.contacts)
	{
		[self watchUser:c.login];
		[self whoUser:c.login];
	}
}

- (void)ping
{
    [self sendMessageToSocket:[NSPMessages ping] appendNewLine:YES];
}

#pragma mark Events

- (void)recvMessage:(NSDictionary *)data
{
    NSString *message = [[data objectForKey:@"content"] objectAtIndex:1];

    [_account receiveMessage:[NSPMessages decode:message] fromUser:[data objectForKey:@"login"]];
}

- (void)recvLogin:(NSDictionary *)data
{
    [_account contactIsNowOnline:[data objectForKey:@"login"]];
}

- (void)recvLogout:(NSDictionary *)data
{
    [_account contactIsNowOffline:[data objectForKey:@"login"]];
	[self whoUser:[data objectForKey:@"login"]];
}

- (void)recvChangeStatus:(NSDictionary *)data
{
    NSString *stateInfos = [[data objectForKey:@"content"] objectAtIndex:1];
    NSRange range = [stateInfos rangeOfString:@":"];
    NSString *state = [stateInfos substringToIndex:range.location];

    [_account contact:[data objectForKey:@"login"] changedState:state];
}

- (void)recvStartTyping:(NSDictionary *)data
{
    [_account contactStartedTyping:[data objectForKey:@"login"]];
}

- (void)recvStopTyping:(NSDictionary *)data
{
    [_account contactStoppedTyping:[data objectForKey:@"login"]];
}

- (void)recvUserInfo:(NSDictionary *)data
{
    if (![[[data objectForKey:@"content"] objectAtIndex:1] isEqualToString:@"rep"])
    {
        [_account receivedInfo:[data objectForKey:@"content"] forUser:[[data objectForKey:@"content"] objectAtIndex:2]];
    }
}

#pragma mark -
#pragma mark Handling replies

- (void)waitReplyToSendMessage:(NSString *)message withObject:(id)object orErrorMessage:(NSString *)error
{
    NSMutableDictionary *dic;

    dic = [[NSMutableDictionary alloc] init];
    if (message)
    {
        [dic setObject:message forKey:@"selector"];
        if (error)
        {
            [dic setObject:error forKey:@"error"];
        }
        if (object)
        {
            [dic setObject:object forKey:@"object"];
        }
    }
    [replyDataPool addObject:dic];
}

- (void)waitReplyToSendMessage:(NSString *)message withObject:(id)object
{
    [self waitReplyToSendMessage:message withObject:object orErrorMessage:nil];
}

- (void)handleReply:(NSString *)message
{
    if ([replyDataPool count] == 0)
        return ;

    NSMutableDictionary *data = [replyDataPool objectAtIndex:0];
    [replyDataPool removeObjectAtIndex:0];
    // Netsoul replies 2 is everything is OK, interesting isn't it?
    if ([message intValue] == 2)
    {
        SEL selector = NSSelectorFromString([data objectForKey:@"selector"]);
        id object = [data objectForKey:@"object"];
        if (object)
            [self performSelector:selector withObject:object];
        else
            [self performSelector:selector];
    }
    else
    {
        NSLog(@"[AdiumSoul] We got an error, it is mal les errors.");
        SEL errorSelector = NSSelectorFromString([data objectForKey:@"error"]);
        if (errorSelector != (SEL)0)
        {
            [self performSelector:errorSelector];
        }
        else
        {
            NSRange range = [message rangeOfString:@" -- "];
            NSLog(@"Command unsuccessful : %@", [message substringFromIndex:range.location + 4]);
        }
    }
}

@end
