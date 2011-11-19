//
//  LoginController.m
//  iSoul
//
//  Created by Cédric Raud on 26/03/09.
//  Copyright 2009 Epita. All rights reserved.
//

#import "LoginController.h"


@implementation LoginController

- (id)initWithISAccount:(ISAccount *)a
{
	self = [super init];

	if (self)
	{
		_account = a;
		self.title = @"Login";
		self.view = nil;

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDisconnect:) name:@"ISC/didDisconnect" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginFail:) name:@"ISC/loginFail" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hostFail:) name:@"ISC/hostFail" object:nil];
	}
	return self;
}

- (void)layoutSubviews
{
	_button.frame = CGRectMake(10, 80, 300, 60);
 	_button.alpha = 0.6;
	[_button setBackgroundImage:_account.imageLoader.contactBackgroundOn forState:UIControlStateNormal];
	_button.adjustsImageWhenHighlighted = NO;
	_button.userInteractionEnabled = NO;

	_label.frame = CGRectMake(10, 55, 300, 25);
	_label.alpha = 0.4;
	_label.textAlignment = UITextAlignmentCenter;
	_label.textColor = [UIColor colorWithRed:0.835 green:0.674 blue:0.443 alpha:1];
	_label.backgroundColor = [UIColor clearColor];
	_label.font = [UIFont systemFontOfSize:14];


	_picture.frame = CGRectMake(20, 90, 34, 40);
	_picture.alpha = 1;
	[_picture setImage:_account.imageLoader.placeholder];

	_login.frame = CGRectMake(80, 98, 200, 30);
	_login.alpha = 1;
	_login.borderStyle = UITextBorderStyleNone;
	_login.text = @"";
	_login.delegate = self;
	_login.keyboardType = UIKeyboardTypeASCIICapable;
	_login.clearButtonMode = UITextFieldViewModeWhileEditing;
	_login.autocapitalizationType = UITextAutocapitalizationTypeNone;
	_login.autocorrectionType = UITextAutocorrectionTypeNo;
	_login.returnKeyType = UIReturnKeyNext;

	_password.frame = CGRectMake(80, 155, 200, 30);
	_password.alpha = 0;
	_password.borderStyle = UITextBorderStyleNone;
	_password.secureTextEntry = YES;
	_password.text = @"";
	_password.delegate = self;
	_password.clearButtonMode = UITextFieldViewModeNever;
	_password.keyboardType = UIKeyboardTypeASCIICapable;
	_password.returnKeyType = UIReturnKeyDone;
	_password.alpha = 0;

	_connecting.frame = CGRectMake(0, 215, 320, 50);
	_connecting.alpha = 0.5;
	_connecting.textAlignment = UITextAlignmentCenter;
	_connecting.textColor = [UIColor orangeColor];
	_connecting.backgroundColor = [UIColor clearColor];
	_connecting.font = [UIFont systemFontOfSize:72];
	_connecting.text = @"*";
	_connecting.alpha = 0;
	_connecting.shadowColor = [UIColor whiteColor];
	_connecting.shadowOffset = CGSizeMake(0, 2);

}


- (void)loadView
{
	UIView *myView = [[UIView alloc] init];

	_button			= [[UIButton alloc] init];
	_label			= [[UILabel alloc] init];
	_picture		= [[UIImageView alloc] init];
	_pictureBorder	= [[UIImageView alloc] init];
	_login			= [[UITextField alloc] init];
	_password		= [[UITextField alloc] init];
	_connecting		= [[UILabel alloc] init];

	[self layoutSubviews];

	[myView addSubview:_button];
	[myView addSubview:_label];
	[myView addSubview:_picture];
	[myView addSubview:_pictureBorder];
	[myView addSubview:_login];
	[myView addSubview:_password];
	[myView addSubview:_connecting];

	self.view = myView;
}

- (void)connect
{
	_button.alpha = 0;
	_login.alpha = 0;
	_password.alpha = 0;
	_pictureBorder.alpha = 0;
	_picture.alpha = 0;
	_label.alpha = 0;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:10];
	_connecting.alpha = 0.8;
	[UIView commitAnimations];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ISC/connect" object:self userInfo:nil];
}

- (void)didDisconnect:(NSNotification *)notification
{
	[self viewWillAppear:YES];
}

- (void)loginFail:(NSNotification *)notification
{
	UIAlertView *alert = [[UIAlertView alloc]	initWithTitle:@"OH NOES"
													message:@"Login / Mdp incorrect."
												   delegate:self
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
}

- (void)hostFail:(NSNotification *)notification
{
	UIAlertView *alert = [[UIAlertView alloc]	initWithTitle:@"OH NOES"
													message:@"Le serveur n'est pas accessible. Veuillez vérifier que vous êtes bien connecté à un réseau."
												   delegate:self
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
}

- (void)viewWillAppear:(BOOL)animated
{
	if ([_account.login isEqualToString:@""])
	{
		[self layoutSubviews];
		[_login becomeFirstResponder];
	}
	else
	{
		[self connect];
	}
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	if (textField == _login)
	{
		_label.text = @"Login";
	}
	else
	{
		[_account.imageLoader loadImageView:_picture withUrl:[NSString stringWithFormat:PICTURL, _login.text]];
		_label.text = @"Password";
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField == _login)
	{
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:1];
		_button.frame = CGRectMake(10, 80, 300, 120);
		_password.alpha = 1;
		[UIView commitAnimations];
		[_password becomeFirstResponder];
	}
	else
	{
		[_password resignFirstResponder];
		_account.login = _login.text;
		_account.password = _password.text;
		[self connect];
	}

	return YES;
}




/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
