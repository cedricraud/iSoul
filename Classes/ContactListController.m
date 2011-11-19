//
//  ContactListController.m
//  iSoul
//
//  Created by Cédric Raud on 27/03/09.
//  Copyright 2009 Epita. All rights reserved.
//

#import "ContactListController.h"


@implementation ContactListController

- (id)initWithISAccount:(ISAccount *)a
{
	if ((self = [super init]) != nil)
	{
		_account = a;
		self.title = @"iSoul";
		self.view = nil;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteContact:) name:@"ISC/deleteContact" object:nil];

	}
	return self;
}

- (void)loadView
{
	UIView *myView = [[UIView alloc] init];

	myView.frame = CGRectMake(0, 0, 320, 480);
	myView.backgroundColor = [UIColor clearColor];

	_loadedContact = 0;
	_interfaceOrientation = UIInterfaceOrientationPortrait;

	_addCell = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
	_addCell.alpha = 0;

	_addButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 300, 40)];
	_addButton.alpha = 0.6;
	_addButton.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	[_addButton setBackgroundImage:_account.imageLoader.contactBackground forState:UIControlStateNormal];
	[_addButton setBackgroundImage:_account.imageLoader.contactBackgroundOn forState:UIControlStateHighlighted];
	[_addButton addTarget:self action:@selector(addContact) forControlEvents:UIControlEventTouchDown];
	_addButton.adjustsImageWhenHighlighted = NO;
	[_addCell addSubview:_addButton];

	_addPicture = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 34, 40)];
	_addPicture.image = _account.imageLoader.placeholder;
	_addPicture.alpha = 0.5;
	[_addCell addSubview:_addPicture];
	_addTextField = [[UITextField alloc] initWithFrame:CGRectMake(60, 22, 150, 30)];
	_addTextField.placeholder = @"Ajouter";
	_addTextField.borderStyle = UITextBorderStyleNone;
	_addTextField.delegate = self;
	_addTextField.keyboardType = UIKeyboardTypeASCIICapable;
	_addTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	_addTextField.autocorrectionType = UITextAutocorrectionTypeNo;
	_addTextField.clearButtonMode = UITextFieldViewModeNever;
	_addTextField.returnKeyType = UIReturnKeyDone;
	[_addCell addSubview:_addTextField];


	_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
	_scrollView.showsVerticalScrollIndicator = NO;
	_scrollView.alwaysBounceVertical = YES;
	_scrollView.delegate = self;

	for (Contact *c in _account.contacts)
	{
		[_scrollView addSubview:c.view];
		[c loadPicture];
	}
	[_scrollView addSubview:_addCell];

	[self reposition];

	[myView addSubview:_scrollView];

	self.view = myView;
}

- (void)deleteContact:(NSNotification *)notification
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationDelay:0.1];
	[self reposition];
	[UIView commitAnimations];
}

- (void)reposition
{
	int	i = 0;
	switch (_interfaceOrientation) {
		case UIInterfaceOrientationPortrait:
		case UIInterfaceOrientationPortraitUpsideDown:
			for (Contact *c in _account.contacts)
			{
				c.view.frame = CGRectMake(0, i  * CONTACT_HEIGHT - 1, 320, CONTACT_HEIGHT);
				[c setOrientation:_interfaceOrientation];
				i++;
			}
			_addCell.frame = CGRectMake(0, i  * CONTACT_HEIGHT - 1, 320, CONTACT_HEIGHT);
			_addCell.hidden = NO;
			[_scrollView setContentSize:CGSizeMake(320, (i + 1) * CONTACT_HEIGHT + 10)];
			_scrollView.frame = CGRectMake(0, 0, 320, 480);
			break;
		case UIInterfaceOrientationLandscapeLeft:
		case UIInterfaceOrientationLandscapeRight:
			for (Contact *c in _account.contacts)
			{
				c.view.frame = CGRectMake((i % 3) * 160, (i / 3) * CONTACT_HEIGHT - 1, 165, CONTACT_HEIGHT);
				[c setOrientation:_interfaceOrientation];
				i++;
			}
			_addCell.hidden = YES;
			//_addCell.frame = CGRectMake((i % 3) * 160, (i / 3) * CONTACT_HEIGHT - 1, 165, CONTACT_HEIGHT);
			[_scrollView setContentSize:CGSizeMake(320, ((i + 2) / 3) * CONTACT_HEIGHT + 10)];
			_scrollView.frame = CGRectMake(0, 0, 480, 320);
			break;
		default:
			break;
	}
}

- (void)loadContacts
{
	if (_loadedContact < [_account.contacts count])
	{
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.5];
		[[[_account.contacts objectAtIndex:_loadedContact] view] setAlpha:1];
		[UIView commitAnimations];
		_loadedContact++;

		if (_loadedContact < 8)
		{
		[NSTimer scheduledTimerWithTimeInterval: 0.075
									 	 target: self
									   selector: @selector(loadContacts)
									   userInfo: nil
										repeats: NO];
		}
		else
		{
			[self loadContacts];
		}


	}
	else
	{
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.5];
		_addCell.alpha = 1;
		[UIView commitAnimations];

	}
}

- (void)scrollToBottom
{
	_scrollView.contentOffset = CGPointMake(0, ([_account.contacts count] - 3)  * CONTACT_HEIGHT - 15);
}



- (void)addContact
{
	_listFrame = _scrollView.frame;
	self.view.userInteractionEnabled = NO;
	_addButton.userInteractionEnabled = NO;
	if ([_account.contacts count] > 3)
	{
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.4];
		_scrollView.frame = CGRectMake(0, 0, 320, 400);
		[self scrollToBottom];
		[UIView commitAnimations];
	}
	if (!_addTextField.selected)
		[_addTextField becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	_addTextField.selected = NO;
	self.view.userInteractionEnabled = YES;
	_addButton.userInteractionEnabled = YES;
	[_addTextField resignFirstResponder];
	if ([_account addContact:[NSString stringWithString:_addTextField.text]])
	{
		Contact *contact = [_account getContact:_addTextField.text];
		[_scrollView addSubview:contact.view];
		[contact loadPicture];
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.4];
		contact.view.alpha = 1;
		[self reposition];
		[UIView commitAnimations];
	}
	if ([_account.contacts count] > 3)
	{
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.4];
		_scrollView.frame = CGRectMake(0, 0, 320, 480);
		[UIView commitAnimations];
	}
	_addTextField.text = @"";
	return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	_interfaceOrientation = toInterfaceOrientation;
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	[self reposition];
	[UIView commitAnimations];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	_addTextField.selected = YES;
	[self addContact];
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	[self textFieldShouldReturn:textField];
}

- (int)getOffset
{
	CGPoint p = _scrollView.contentOffset;
	return p.y;
}

- (void)viewDidAppear:(BOOL)animated
{
	if (!_loadedContact)
		[self loadContacts];
	else
	{
		[_scrollView addSubview:_account.current.view];
		[self reposition];
	}
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

- (void)viewDidUnload {

}


- (void)dealloc {
    [super dealloc];
}

#pragma mark ScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	_scrollView.clearsContextBeforeDrawing = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	_scrollView.clearsContextBeforeDrawing = YES;
}


@end
