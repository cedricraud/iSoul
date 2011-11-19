//
//  SettingsController.h
//  iSoul
//
//  Created by Cédric Raud on 21/07/09.
//  Copyright 2009 Epita. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ISAccount.h"


@interface SettingsController : UIViewController<UITextFieldDelegate> {
	ISAccount *_account;
	UITextField *_location;
	UITextField *_userdata;
	UIButton *_button;
	UIButton *_disconnectButton;
	UIInterfaceOrientation	_interfaceOrientation;
}

- (id)initWithISAccount:(ISAccount *)a;


@end
