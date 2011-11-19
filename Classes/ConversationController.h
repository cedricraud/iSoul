//
//  ConversationController.h
//  iSoul
//
//  Created by Cédric Raud on 06/06/09.
//  Copyright 2009 Epita. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "ISAccount.h"

@interface ConversationController : UIViewController<UIWebViewDelegate, UITextFieldDelegate, MFMailComposeViewControllerDelegate> {
	ISAccount *_account;
	UIWebView *_messageView;
	CGRect _messageViewFrame;
	UITextField *_input;
	CGRect _inputFrame;
	UIView *_contactView;
	CGRect _frame;
}
- (id)initWithISAccount:(ISAccount *)a;


@end
