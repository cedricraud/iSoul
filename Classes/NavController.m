//
//  NavController.m
//  iSoul
//
//  Created by Cédric Raud on 26/03/09.
//  Copyright 2009 Epita. All rights reserved.
//

#import "NavController.h"


@implementation NavController

- (id)initWithRootViewController:(UIViewController *)view account:(ISAccount *)a
{
	if ((self = [super initWithRootViewController:view]) != nil) {
		_account = [a retain];
		_settingsController = [[SettingsController alloc] initWithISAccount:_account];
		_contactListController = [[ContactListController alloc] initWithISAccount:_account];
		_conversationController = [[ConversationController alloc] initWithISAccount:_account];
		_interfaceOrientation = self.interfaceOrientation;
		self.delegate = self;
		self.navigationBarHidden = YES;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disconnect:) name:@"ISC/disconnect" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didConnect:) name:@"ISC/didConnect" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewConversation:) name:@"ISC/viewConversation" object:nil];
		//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPanel:) name:@"ISC/newMessage" object:nil];
		
		/*
		 [self pushViewController:_contactListController animated:YES];
		 _account.login = @"raud_c";
		 */
		
		_frame = CGRectMake(0, 0, 320, 480);
		self.view.frame = _frame;
		
		self.view.backgroundColor = [UIColor clearColor];
	}
	
	return self;
}

- (void)dealloc
{
	[_account release];
	[_contactListController release];
	[_conversationController release];
	[_settingsController release];
	
	[super dealloc];
}

/*
 - (void)showPanel:(NSNotification *)notification
 {
 [UIView beginAnimations:nil context:nil];
 [UIView setAnimationDuration:0.4];
 CGRect frame = _frame;
 frame.origin.y += 30;
 frame.size.height -= 30;
 self.view.frame = frame;
 [UIView commitAnimations];
 
 }
 
 - (void)hidePanel:(NSNotification *)notification
 {
 [UIView beginAnimations:nil context:nil];
 [UIView setAnimationDuration:0.4];
 self.view.frame = _frame;
 [UIView commitAnimations];
 }
 */

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	[super pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
	if ([self.viewControllers count] == 3)
	{
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.4];
		_account.current.view.frame = _contactFrame;
		[UIView commitAnimations];
	}
	return [super popViewControllerAnimated:animated];
}

- (void)didConnect:(NSNotification *) notification
{
	[self pushViewController:_contactListController animated:YES];
	NSLog(@"didConnect");
}

- (void)disconnect:(NSNotification *) notification
{
	if ([self.viewControllers count] == 3)
		[_contactListController.view addSubview:_account.current.view];
	[self popToRootViewControllerAnimated:YES];
}

- (void)viewConversation:(NSNotification *) notification
{
	NSLog(@"viewConversation");
	if ([self.viewControllers count] == 3)
	{
		[self popViewControllerAnimated:NO];//UIInterfaceOrientationIsPortrait(self.interfaceOrientation)];
		return;
	}
	NSString *user = [[notification userInfo] objectForKey:@"user"];
	_account.current = [_account getContact:user];
	_contactFrame = _account.current.view.frame;
	_contactFrame.origin.y -= [_contactListController getOffset];
	[self.view addSubview:_account.current.view];
	_account.current.view.frame = _contactFrame;
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.4];
	_account.current.view.frame = CGRectMake(0, -4, UIInterfaceOrientationIsPortrait(_interfaceOrientation) ? 320 : 480, 60);
	[UIView commitAnimations];
	
	
	if (_account.current.root)
		[self pushViewController:_settingsController animated:YES];
	else
		[self pushViewController:_conversationController animated:YES];
}


- (void)viewDidLoad {
	[super viewDidLoad];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return [self.viewControllers count] > 1 || UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	_interfaceOrientation = toInterfaceOrientation;
	[self.visibleViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	[_settingsController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	if ([self.viewControllers count] == 3)
	{
		[_contactListController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
		_account.current.view.frame = CGRectMake(0, -4, UIInterfaceOrientationIsPortrait(_interfaceOrientation) ? 320 : 480, 60);
	}
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


@end
