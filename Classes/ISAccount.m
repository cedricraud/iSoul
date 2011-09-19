//
//  ISAccount.m
//  iSoul
//
//  Created by Cédric Raud on 23/03/09.
//  Copyright 2009 Epita. All rights reserved.
//

#import "ISAccount.h"

@implementation ISAccount

@synthesize password, status, location, userdata, searching, contacts, talking, imageLoader, searchContact, current;

- (id)init
{
	login = @"";
	password = @"";
	status = @"connection";
	location = [[[UIDevice currentDevice] platformString] copy];
	userdata = @"Rocking Chair !";
	searching = nil;
	current = nil;
	contacts = [[NSMutableArray alloc] init];
	talking = [[NSMutableArray alloc] init];
	imageLoader = [[ImageLoader alloc] init];
	searchContact = [[Contact alloc] initWithLogin:NOLOGIN imageLoader:imageLoader];
	_prefs = [NSUserDefaults standardUserDefaults];
	
	if ([_prefs stringForKey:@"last"])
	{
		self.login = [_prefs stringForKey:@"last"];
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteContact:) name:@"ISC/deleteContact" object:nil];

	
	/*
    [self setLogin:@"raud_c"];
	[contacts addObject:[[Contact alloc] initWithLogin:@"philip_o" imageLoader:imageLoader]];
	[contacts addObject:[[Contact alloc] initWithLogin:@"de-sai_f" imageLoader:imageLoader]];
	[contacts addObject:[[Contact alloc] initWithLogin:@"ghalmi_j" imageLoader:imageLoader]];
	[contacts addObject:[[Contact alloc] initWithLogin:@"seine_w" imageLoader:imageLoader]];
	[contacts addObject:[[Contact alloc] initWithLogin:@"fahmi_m" imageLoader:imageLoader]];
	[contacts addObject:[[Contact alloc] initWithLogin:@"le-rou_j" imageLoader:imageLoader]];
	[contacts addObject:[[Contact alloc] initWithLogin:@"vigour_c" imageLoader:imageLoader]];
    */
	return self;
}

- (NSString*)login
{
	return login;
}

- (void)setLogin:(NSString*)value
{
	if ([login isEqualToString:value])
		return;
	login = value;
	if ([login isEqualToString:@""])
		return;
	if ([_prefs objectForKey:login])
	{
		NSDictionary* dict = [_prefs objectForKey:login];
		NSArray* users = [dict objectForKey:@"contacts"];
		@try
		{
			password = [[dict objectForKey:@"password"] isKindOfClass:[NSString class]] && [[dict objectForKey:@"password"] length] > 0 ? [dict objectForKey:@"password"] : @"lol";
			location = [[dict objectForKey:@"location"] isKindOfClass:[NSString class]] && [[dict objectForKey:@"location"] length] > 0 ? [dict objectForKey:@"location"] : @"iPhone";
			userdata = [[dict objectForKey:@"userdata"] isKindOfClass:[NSString class]] &&  [[dict objectForKey:@"userdata"] length] > 0 ? [dict objectForKey:@"userdata"] : @"iSoul";
		}
		@catch(NSException* exception)
		{
			NSLog(@"Prefs: Caught %@: %@", [exception name],  [exception reason]);
		}
		for(NSString* user in users)
		{
			Contact* contact = [[Contact alloc] initWithLogin:user imageLoader:imageLoader];
			if ([user isEqualToString:login])
				contact.root = YES;
			[contacts addObject:contact];			
		}
	}
	else
	{
		Contact* contact = [[Contact alloc] initWithLogin:login imageLoader:imageLoader];
		contact.root = YES;
		[contacts addObject:contact];		
	}	
}

- (void)didConnect
{
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ISC/didConnect" object:self userInfo:nil];
	NSLog(@"didConnect");
}

- (void)didDisconnect
{
	login = @"";
	
	[_prefs removeObjectForKey:@"last"];
	[_prefs synchronize];

	[[NSNotificationCenter defaultCenter] postNotificationName:@"ISC/didDisconnect" object:self userInfo:nil];

	NSLog(@"didDisconnect");
}

- (void)connectionProgressStep:(e_status)step
{
	switch(step)
	{
		case NETSOUL_STEP_CONNECTING:
			NSLog(@"connectionProgressStep:NETSOUL_STEP_CONNECTING");
			break;
		case NETSOUL_STEP_CONNECTION_ESTABLISHED:
			NSLog(@"connectionProgressStep:NETSOUL_STEP_CONNECTION_ESTABLISHED");
			break;
		case NETSOUL_STEP_AUTH_AG_REQUEST:
			NSLog(@"connectionProgressStep:NETSOUL_STEP_AUTH_AG_REQUEST");
			break;
		case NETSOUL_STEP_AUTHENTICATION:
			NSLog(@"connectionProgressStep:NETSOUL_STEP_AUTHENTICATION");
			break;
		case NETSOUL_STEP_FAILURE:
			[contacts removeAllObjects];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"ISC/loginFail" object:self userInfo:nil];
			NSLog(@"connectionProgressStep:NETSOUL_STEP_FAILURE");
			break;
		case NETSOUL_STEP_HOST_FAIL:
			[contacts removeAllObjects];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"ISC/hostFail" object:self userInfo:nil];
			NSLog(@"connectionProgressStep:NETSOUL_HOST_FAIL");
			break;
	}
}

- (void)receiveMessage:(NSString*)message fromUser:(NSString*)user
{
	Contact* c = [self getContact:user];
	
	if (!c)
		c = [[Contact alloc] initWithLogin:user imageLoader:imageLoader];
	
	[c.messages addObject:[[ISMessage alloc] initWithDate:[NSDate date] content:message received:YES]];
	c.unread += 1;
	[self.talking addObject:c];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ISC/newMessage" object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys: user, @"user", nil]];
	//NSLog(@"receiveMessage:%@ fromUser:%@", message, user);
}

- (void)sendMessage:(NSString *)message toUser:(NSString *)user
{
	Contact* c = [self getContact:user];
	
	if (!c)
		c = [[Contact alloc] initWithLogin:user imageLoader:imageLoader];
	
	[c.messages addObject:[[ISMessage alloc] initWithDate:[NSDate date] content:message received:NO]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ISC/sendMessage" object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys: message, @"message", user, @"user", nil]];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ISC/newMessage" object:self userInfo:nil];

}

- (void)disconnectedFromServer
{
	NSLog(@"disconnectedFromServer");
}

- (void)contactIsNowOnline:(NSString*)user
{
	NSLog(@"contactIsNowOnline:%@", user);
}

- (void)contactIsNowOffline:(NSString*)user
{
	NSLog(@"contactIsNowOffline:%@", user);
	Contact* c = [self getContact:user];
	if (c)
	{
		c.status = @"offline";
		c.location = nil;
	}
}

- (void)contact:(NSString*)user changedState:(NSString*)state
{
	NSLog(@"contact:%@ changedState:%@", user, state);
	Contact* c = [self getContact:user];
	if (c)
		c.status = state;
}

- (void)contactStartedTyping:(NSString*)user
{
	NSLog(@"contactStartedTyping:%@", user);
}

- (void)contactStoppedTyping:(NSString*)user
{
	NSLog(@"contactStoppedTyping:%@", user);
}

- (void)receivedInfo:(NSArray*)content forUser:(NSString*)user
{
	Contact* c = [self getContact:[content objectAtIndex:2]];
	if (c)
	{
		c.location = [NSPMessages decode:[content objectAtIndex:9]];
		NSArray* a = [[content objectAtIndex:11] componentsSeparatedByString:@":"];
		c.status = [a objectAtIndex:0];
	}
	NSLog(@"receivedInfo:%@ forUser:%@", content, user);
}

- (Contact*)getContact:(NSString*) l
{
	for (Contact* c in contacts)
	{
		if(c.login && [c.login isEqualToString:l])
			return c;
	}
	return nil;
}

- (Contact*)addContact:(NSString*)l
{
	NSUInteger length = [l length];
	if (length >= 2 && length <= 10)
		if ([self getContact:l])
			return nil;
		else
		{
			Contact* c = [[Contact alloc] initWithLogin:l imageLoader:imageLoader];
			if (c)
			{
				[self.contacts addObject:c];
				[[NSNotificationCenter defaultCenter] postNotificationName:@"ISC/watchUser" object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys: l, @"user", nil]];
				[self save];
				return c;
			}
			else
				return nil;
		}
	else
		return nil;
}

- (void)deleteContact:(NSNotification*)notification
{
	NSString* user = [[notification userInfo] objectForKey:@"user"];
	Contact* contact = [self getContact:user];
	if (contact)
	{
		[contacts removeObject:contact];
		[self save];
	}
}

- (void)disconnect
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ISC/disconnect" object:self userInfo:nil];
}

- (void)save
{
	NSMutableArray* users = [NSMutableArray arrayWithCapacity:[contacts count]];
	for(Contact* contact in contacts)
		[users addObject:contact.login];
	[_prefs removeObjectForKey:login];
	if ([location length] == 0)
		location = [[[UIDevice currentDevice] platformString] copy];
	[_prefs setObject:[NSDictionary dictionaryWithObjectsAndKeys: users, @"contacts", location, @"location", userdata, @"userdata", password, @"password", nil] forKey:login];
	[_prefs removeObjectForKey:@"last"];
	[_prefs setObject:login forKey:@"last"];
	[_prefs synchronize];
}

@end
