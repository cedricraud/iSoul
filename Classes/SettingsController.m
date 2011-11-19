//
//  SettingsController.m
//  iSoul
//
//  Created by Cédric Raud on 21/07/09.
//  Copyright 2009 Epita. All rights reserved.
//

#import "SettingsController.h"


@implementation SettingsController

- (id)initWithISAccount:(ISAccount *)a
{
	if ((self = [super init]) != nil)
	{
		_account = a;
		self.view = nil;
	}
	return self;
}

- (void)loadView
{
	UIView *myView = [[UIView alloc] init];

	_button = [[UIButton alloc] initWithFrame:CGRectMake(10, 70, 300, 105)];
 	_button.alpha = 0.6;
	[_button setBackgroundImage:_account.imageLoader.contactBackground forState:UIControlStateNormal];
	_button.userInteractionEnabled = NO;
	_button.adjustsImageWhenHighlighted = NO;
	[myView addSubview:_button];

	_location = [[UITextField alloc] initWithFrame:CGRectMake(20, 85, 280, 30)];
	_location.borderStyle = UITextBorderStyleNone;
	_location.text = _account.location;
	_location.delegate = self;
	_location.keyboardType = UIKeyboardTypeASCIICapable;
	_location.clearButtonMode = UITextFieldViewModeWhileEditing;
	_location.autocapitalizationType = UITextAutocapitalizationTypeNone;
	_location.autocorrectionType = UITextAutocorrectionTypeNo;
	_location.returnKeyType = UIReturnKeyDone;
	UILabel *locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
	locationLabel.text = @"   Location";
	locationLabel.textColor = [UIColor lightGrayColor];
	locationLabel.backgroundColor = [UIColor clearColor];
	locationLabel.font = [UIFont systemFontOfSize:12];
	_location.leftView = locationLabel;
	_location.leftViewMode = UITextFieldViewModeAlways;
	_location.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	[_location setBackground:_account.imageLoader.contactBackground];
	[myView addSubview:_location];

	_userdata = [[UITextField alloc] initWithFrame:CGRectMake(20, 130, 280, 30)];
	_userdata.borderStyle = UITextBorderStyleNone;
	_userdata.text = _account.userdata;
	_userdata.delegate = self;
	_userdata.clearButtonMode = UITextFieldViewModeWhileEditing;
	_userdata.keyboardType = UIKeyboardTypeASCIICapable;
	_userdata.returnKeyType = UIReturnKeyDone;
	UILabel *userdataLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
	userdataLabel.text = @"   User Data";
	userdataLabel.textColor = [UIColor lightGrayColor];
	userdataLabel.backgroundColor = [UIColor clearColor];
	userdataLabel.font = [UIFont systemFontOfSize:12];
	_userdata.leftView = userdataLabel;
	_userdata.leftViewMode = UITextFieldViewModeAlways;
	_userdata.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	[_userdata setBackground:_account.imageLoader.contactBackground];
	[myView addSubview:_userdata];

	_disconnectButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 200, 300, 40)];
 	_disconnectButton.alpha = 0.6;
	[_disconnectButton setBackgroundImage:_account.imageLoader.contactBackgroundOn forState:UIControlStateNormal];
	[_disconnectButton setBackgroundImage:_account.imageLoader.contactBackgroundOn forState:UIControlStateNormal];
	[_disconnectButton addTarget:self action:@selector(disconnect) forControlEvents:UIControlEventTouchDown];
	[_disconnectButton setTitle:@"Disconnect" forState:UIControlStateNormal];
	[_disconnectButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	_disconnectButton.contentMode = UIViewContentModeCenter;
	_disconnectButton.adjustsImageWhenHighlighted = NO;
	[myView addSubview:_disconnectButton];

	_interfaceOrientation = self.interfaceOrientation;

	self.view = myView;
}

- (void)reposition
{
	switch (_interfaceOrientation) {
		case UIInterfaceOrientationPortrait:
		case UIInterfaceOrientationPortraitUpsideDown:
			_button.frame = CGRectMake(10, 70, 300, 105);
			_location.frame = CGRectMake(20, 85, 280, 30);
			_userdata.frame = CGRectMake(20, 130, 280, 30);
			_disconnectButton.frame = CGRectMake(10, 200, 300, 40);
			break;
		case UIInterfaceOrientationLandscapeLeft:
		case UIInterfaceOrientationLandscapeRight:
			_button.frame = CGRectMake(10, 70, 460, 105);
			_location.frame = CGRectMake(20, 85, 440, 30);
			_userdata.frame = CGRectMake(20, 130, 440, 30);
			_disconnectButton.frame = CGRectMake(10, 200, 460, 40);
		default:
			break;
	}

}

- (void)viewWillAppear:(BOOL)animated
{
	_location.text = _account.location;
	_userdata.text = _account.userdata;
	[self reposition];
}



- (void)viewWillDisappear:(BOOL)animated
{
	[_account save];
}

- (void)disconnect
{
	[_account disconnect];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	if (textField == _location)
	{
		[_location setBackground:_account.imageLoader.contactBackgroundOn];
		[_userdata setBackground:_account.imageLoader.contactBackground];
	}
	else
	{
		[_location setBackground:_account.imageLoader.contactBackground];
		[_userdata setBackground:_account.imageLoader.contactBackgroundOn];
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField == _location)
		_account.location = _location.text;
	else
		if (textField == _userdata)
				_account.userdata = _userdata.text;

	[textField setBackground:_account.imageLoader.contactBackground];
	[textField resignFirstResponder];
	return YES;
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (YES);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	_interfaceOrientation = toInterfaceOrientation;
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:duration];
	[self reposition];
	[UIView commitAnimations];
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


- (void)dealloc {
    [super dealloc];
}


@end
