//
//  Contact.m
//  iSoul
//
//  Created by Cédric Raud on 27/03/09.
//  Copyright 2009 Epita. All rights reserved.
//

#import "Contact.h"


@implementation Contact

@synthesize login, status, location, userdata, messages, unread, root;

- (id)initWithLogin:(NSString *)l imageLoader:(ImageLoader *)i
{
	if ((self = [super init]) != nil) {
		login = [l copy];
		name = [login copy];
		status = [@"actif" retain];
		location = nil;
		userdata = nil;
		messages = [[NSMutableArray alloc] init];
		root = NO;
		_imageLoader = [i retain];
		_interfaceOrientation = UIInterfaceOrientationPortrait;

		view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
		view.alpha = 0;
		view.clearsContextBeforeDrawing = NO;

		if (!view) {
			NSLog(@"*** Warning: cannot init view while initing a Contact. Returning nil.");
			[self release];
			return nil;
		}

		_button = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 300, 40)];
		_button.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		_button.alpha = 0.5;
		_button.adjustsImageWhenHighlighted = NO;
		[_button setBackgroundImage:_imageLoader.contactBackground forState:UIControlStateNormal];
		[_button setBackgroundImage:_imageLoader.contactBackgroundOn forState:UIControlStateSelected];
		[_button addTarget:self action:@selector(viewConversation) forControlEvents:UIControlEventTouchUpInside];
		[_button addTarget:self action:@selector(swipe) forControlEvents:UIControlEventTouchDragInside];
		[view addSubview:_button];

		_deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(265, 17, 35, 35)];
		_deleteButton.alpha = 0;
		[_deleteButton setBackgroundImage:_imageLoader.deleteContact forState:UIControlStateNormal];
		[_deleteButton setBackgroundImage:_imageLoader.deleteContactOn forState:UIControlStateHighlighted];
		[_deleteButton addTarget:self action:@selector(deleteContact) forControlEvents:UIControlEventTouchDown];
		[view addSubview:_deleteButton];

		_mailButton = [[UIButton alloc] initWithFrame:CGRectMake(265, 17, 35, 35)];
		_mailButton.alpha = 0;
		[_mailButton setBackgroundImage:_imageLoader.mailButton forState:UIControlStateNormal];
		[_mailButton addTarget:self action:@selector(sendMail) forControlEvents:UIControlEventTouchDown];
		[view addSubview:_mailButton];

		_picture = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 34, 40)];
		_picture.image = nil;
		[view addSubview:_picture];

		/*
		 _pictureBorder = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 34, 40)];
		 [_pictureBorder setImage:_imageLoader.loginBorder];
		 [view addSubview:_pictureBorder];*/

		_statusImageView = [[UIImageView alloc] initWithFrame:CGRectMake(34, 40, 20, 20)];
		[_statusImageView setImage:[UIImage imageNamed:@"offline.png"]];
		_statusImageView.alpha = 0;
		[view addSubview:_statusImageView];

		_nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, 200, 30)];
		_nameLabel.backgroundColor = [UIColor clearColor];
		_nameLabel.alpha = 0.5;
		_nameLabel.font = [UIFont systemFontOfSize:16];
		[view addSubview:_nameLabel];

		_locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 30, 250, 30)];
		_locationLabel.textColor = [UIColor grayColor];
		_locationLabel.backgroundColor = [UIColor clearColor];
		_locationLabel.font = [UIFont systemFontOfSize:12];
		_locationLabel.text = @"";
		_locationLabel.adjustsFontSizeToFitWidth = YES;
		[view addSubview:_locationLabel];

		_unreadLabel = [[UILabel alloc] initWithFrame:CGRectMake(290, 18, 25, 30)];
		_unreadLabel.textColor = [UIColor orangeColor];
		_unreadLabel.textAlignment = UITextAlignmentCenter;
		_unreadLabel.backgroundColor = [UIColor clearColor];
		_unreadLabel.font = [UIFont boldSystemFontOfSize:16];
		_unreadLabel.text = @"";
		_unreadLabel.alpha = 0;
		[view addSubview:_unreadLabel];
		
		self.login = login; // Do not remove: refreshes the view...
	}

	return self;
}

- (void)dealloc
{
	[login release];
	[name release];
	[status release];
	[location release];
	[userdata release];
	[messages release];
	
	[_statusImageView release];
	[_picture release];
	[_pictureBorder release];
	[_button release];
	[_deleteButton release];
	[_mailButton release];
	[_nameLabel release];
	[_locationLabel release];
	[_unreadLabel release];
   [view release];
	[_imageLoader release];
	
	[super dealloc];
}

- (void)cancelSwipe
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	_deleteButton.alpha = 0;
	[UIView commitAnimations];
}

- (void)swipe
{
	if (!_button.selected && UIInterfaceOrientationIsPortrait(_interfaceOrientation) && !root)
	{
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.3];
		_deleteButton.alpha = 0.6;
		[UIView commitAnimations];
		[NSTimer scheduledTimerWithTimeInterval: 2
										 target: self
									   selector: @selector(cancelSwipe)
									   userInfo: nil
										repeats: NO];
	}
}

- (void)deleteContact
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ISC/deleteContact" object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys: login, @"user", nil]];
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	self.view.alpha = 0;
	[UIView commitAnimations];
}

- (UIView *)view
{
	return view;
}

- (void)loadPicture
{
	[_imageLoader loadImageView:_picture withUrl:[NSString stringWithFormat:PICTURL, login]];
}


- (void)setLocation:(NSString *)_value
{
	if (!location) location = [NSString new];
	[location autorelease];
	if (_value) {
		if (location.length > 0) location = [location stringByAppendingString:@", "];
		location = [location stringByAppendingString:_value];
	}
	[location retain];
	_locationLabel.text = location;
}

- (NSString *)location;
{
	return location;
}

- (void)setStatus:(NSString *)_value
{
	NSLog(@"state : %@", _value);
	status = [_value copy];
	if ([_value isEqualToString:@"offline"]) {
		_nameLabel.alpha = 0.5;
		_statusImageView.alpha = 0;
	} else if ([_value isEqualToString:@"actif"] || [_value isEqualToString:@"connection"]) {
		_nameLabel.alpha = 1;
		_statusImageView.alpha = 1;
		_statusImageView.image = [UIImage imageNamed:@"online.png"];
	} else {
		_nameLabel.alpha = 1;
		_statusImageView.alpha = 1;
		_statusImageView.image = [UIImage imageNamed:@"away.png"];
	}
}

- (void)setLogin:(NSString *)_value
{
	if (_value) {
		[login autorelease];
		login = [_value retain];
		_nameLabel.text = login;
	}
}

- (NSString *)login
{
	return login;
}

- (void)setUnread:(int)_value
{

	if (_value > 0 && !_button.selected)
	{
		if (unread == 0)
		{
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:1];
			_unreadLabel.alpha = 1;
			[UIView commitAnimations];
		}
		_unreadLabel.text = [NSString stringWithFormat:@"%i", _value];
	}
	else
		_unreadLabel.text = @"";
	unread = _value;
}

- (void)setOrientation:(UIInterfaceOrientation)orientation
{
	_interfaceOrientation = orientation;
	switch (_interfaceOrientation) {
		case UIInterfaceOrientationPortrait:
		case UIInterfaceOrientationPortraitUpsideDown:
			_locationLabel.frame = CGRectMake(60, 30, 250, 30);
			_unreadLabel.frame = CGRectMake(270, 18, 25, 30);
			_mailButton.frame = CGRectMake(265, 17, 35, 35);
			break;
		case UIInterfaceOrientationLandscapeLeft:
		case UIInterfaceOrientationLandscapeRight:
			_locationLabel.frame = CGRectMake(60, 30, 90, 30);
			_unreadLabel.frame = CGRectMake(125, 18, 25, 30);
			_mailButton.frame = CGRectMake(425, 17, 35, 35);
		default:
			break;
	}
	if (_interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown && !_button.selected && !root)
		_deleteButton.alpha = 0.6;
	else
		_deleteButton.alpha = 0;
}

- (int)unread
{
	return unread;
}

- (id)updateWithLogin:(NSString *)l
{
	self.login = l;

	return view;
}


- (void)endBounce:(NSString *)animationID finished:(BOOL)finished context:(void *)context
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.15];
	_picture.transform = CGAffineTransformIdentity;
	[UIView commitAnimations];
}

- (void)sendMail
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ISC/sendMail" object:self userInfo:nil];
}

- (void)viewConversation
{
	if (_deleteButton.alpha > 0)
		return;


	if (!_button.selected)
	{
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.4];
		_unreadLabel.alpha = 0;
		if (!root)
		_mailButton.alpha = 0.5;
		[UIView commitAnimations];
	}
	else
		_mailButton.alpha = 0;

	_deleteButton.alpha = 0;
	_button.selected = !_button.selected;
	if (_interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown && !_button.selected)
		_deleteButton.alpha = 0.6;
	CGRect frame = _button.frame;
	frame.size.width = view.frame.size.width - 20;
	_button.frame = frame;

	[[NSNotificationCenter defaultCenter] postNotificationName:@"ISC/viewConversation" object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys: login, @"user", nil]];


	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.15];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(endBounce: finished: context:)];
	_picture.transform = CGAffineTransformMakeScale(1.5, 1.5);
	[UIView commitAnimations];
}

@end
