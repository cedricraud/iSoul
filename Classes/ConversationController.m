//
//  ConversationController.m
//  iSoul
//
//  Created by Cédric Raud on 06/06/09.
//  Copyright 2009 Epita. All rights reserved.
//

#import "ConversationController.h"


@implementation ConversationController

- (id)initWithISAccount:(ISAccount*)a
{
	self = [super init];
	
	if (self) 
	{
		_account = a;
		self.title = @"iSoul";
		self.view = nil;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadMessages:) name:@"ISC/newMessage" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendMail:) name:@"ISC/sendMail" object:nil];
	}
	return self;
}

- (void)loadView
{
	UIView*	myView = [[UIView alloc] init];
	
	myView.frame = CGRectMake(0, 0, 320, 418);
	[myView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
	
	_contactView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 58)];
	[myView addSubview:_contactView];

	_messageViewFrame = CGRectMake(0, 60, 320, 310);
	_messageView = [[UIWebView alloc] init];
	_messageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	_messageView.frame = _messageViewFrame;
	_messageViewFrame.size.height += 60;
	_messageView.delegate = self;
	_messageView.backgroundColor = [UIColor clearColor];
	_messageView.opaque = NO;
	_messageView.scalesPageToFit = NO;
	[myView addSubview:_messageView];
	
	_inputFrame = CGRectMake(10, 380, 300, 30);
	_input = [[UITextField alloc] init];
	_input.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
	_input.frame = _inputFrame;
	_inputFrame.origin.y += 60;
	_input.delegate = self;
	_input.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 30)];
	_input.leftViewMode = UITextFieldViewModeAlways;
	_input.enablesReturnKeyAutomatically = YES;
	_input.returnKeyType = UIReturnKeySend;
	_input.clearButtonMode = UITextFieldViewModeWhileEditing;
	_input.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	[_input setBackground:_account.imageLoader.contactBackgroundOn];
	[myView addSubview:_input];
	
	self.view = myView;
}

- (NSString*)htmlForUser:(Contact*)c forMail:(Boolean)b
{
	NSMutableString* html = [[NSMutableString alloc] initWithString:@"<html><head><style type='text/css'>html, body{font-family:Sans-serif;}</style></head><body style='background: transparent none repeat scroll 0% 0%; -moz-background-clip: -moz-initial; -moz-background-origin: -moz-initial; -moz-background-inline-policy: -moz-initial;'>"];
//	NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
	
//	[dateFormatter setDateFormat:@"HH:mm:ss"];
	for (ISMessage* message in c.messages)
	{
		[html appendFormat:@"<b>%@ : </b>%@<br />", 
//				[dateFormatter stringFromDate:message.date], 
				(message.received ? c.login : _account.login),
				[message.content stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"]];
	}
	if (!b)
	[html appendString:@"<script type='text/javascript'>function scroll(){document.body.scrollTop = document.body.scrollHeight};scroll();</script></body></html>"];
//	[dateFormatter release];
	return html;
}

- (void)loadMessages:(NSNotification*) notification
{
	if (_account.current)
	{
		[_messageView loadHTMLString:[self htmlForUser:_account.current forMail:NO] baseURL:nil];
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	if (_account.current)
	{
		self.title = _account.current.login;
		_messageView.alpha = 0;

		[self loadMessages:nil];
		if ([_account.current.messages count] == 0)
			[_input becomeFirstResponder];
	}
}

- (void)viewWillDisappear:(BOOL)animated
{
//	_account.current.cell.frame = _frame;
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.4];	
	[_input resignFirstResponder];
	[UIView commitAnimations];
	if (_account.current)
		_account.current.unread = 0;
}

-(void)sendMail:(NSNotification*)notification 
{
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	[picker setSubject:[NSString stringWithFormat:@"Conversation Netsoul avec %@", _account.current.login]];
	
	
	// Set up recipients
	NSArray *toRecipients = [NSArray arrayWithObject:[NSString stringWithFormat:@"%@@epitech.eu", _account.login]];

	[picker setToRecipients:toRecipients];
	
	
	// Fill out the email body text
	NSString *emailBody = [self htmlForUser:_account.current forMail:YES];
	[picker setMessageBody:emailBody isHTML:YES];
	
	[self presentModalViewController:picker animated:YES];
    [picker release];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{	
	[self dismissModalViewControllerAnimated:YES];
}


#pragma mark TextField



- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.4];
	_messageViewFrame = _messageView.frame;
	CGRect frame = _messageViewFrame;
	frame.size.height -= UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? 215 : 160;
	_messageView.frame = frame;
	
	_inputFrame = _input.frame;
	frame = _inputFrame;
	frame.origin.y -= UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? 215 : 160;
	_input.frame = frame;
	[UIView commitAnimations];
	_messageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	_input.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;

	[_messageView stringByEvaluatingJavaScriptFromString:@"scroll()"];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.4];	
	_messageView.frame = _messageViewFrame;
	_input.frame = _inputFrame;
	[UIView commitAnimations];
	_messageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	_input.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
}

 - (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[_account sendMessage:[[NSString stringWithString:_input.text] retain] toUser:_account.current.login];
	_input.text = @"";
	return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[_input resignFirstResponder];
	[self loadMessages:nil];

}

#pragma mark Webview


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.4];	
	_messageView.alpha = 1;
	[UIView commitAnimations];
}


@end
