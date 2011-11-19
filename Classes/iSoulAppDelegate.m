//
//  iSoulAppDelegate.m
//  iSoul
//
//  Created by Cédric Raud on 21/03/09.
//  Copyright Epita 2009. All rights reserved.
//

#import "iSoulAppDelegate.h"

@implementation iSoulAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
	application.statusBarHidden = YES;

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alertMessage:) name:@"ISC/newMessage" object:nil];

	_account = [[ISAccount alloc] init];

	_network = [[iSoulCore alloc] initWithISAccount:_account];

	_loginController = [[LoginController alloc] initWithISAccount:_account];

	_navController = [[NavController alloc] initWithRootViewController:_loginController account:_account];

	_backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
	[_backgroundView setImage:_account.imageLoader.background];
	_backgroundView.alpha = 0.4;
	[window addSubview:_backgroundView];

	[window addSubview:_navController.view];
    [window makeKeyAndVisible];
}

- (void)endMessage:(NSString *)animationID finished:(BOOL)finished context:(void *)context
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	_backgroundView.alpha = 0.4;
	[UIView commitAnimations];
}

- (void)alertMessage:(NSNotification *)notification
{
	if ([notification userInfo])
	{
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.3];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(endMessage: finished: context:)];
		_backgroundView.alpha = 0.6;
		[UIView commitAnimations];
	}
}

- (void)dealloc {
	[_account save];

	[_network disconnect];
	[_network release];
	[_account release];
	[_navController release];
    [window release];
    [super dealloc];
}


@end
