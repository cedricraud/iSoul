//
//  NavController.h
//  iSoul
//
//  Created by Cédric Raud on 26/03/09.
//  Copyright 2009 Epita. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ISAccount.h"
#import "ContactListController.h"
#import "ConversationController.h"
#import "SettingsController.h"

@interface NavController : UINavigationController<UINavigationControllerDelegate>{
	ISAccount*				_account;
	ContactListController*	_contactListController;
	ConversationController*	_conversationController;
	SettingsController*		_settingsController;
	CGRect					_frame;
	CGRect					_contactFrame;
	UIInterfaceOrientation	_interfaceOrientation;
}

- (id) initWithRootViewController:(UIViewController *)view account:(ISAccount*)a;

@end
