//
//  LoginController.h
//  iSoul
//
//  Created by Cédric Raud on 26/03/09.
//  Copyright 2009 Epita. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ISAccount.h"

@interface LoginController : UIViewController<UITextFieldDelegate> {
	ISAccount*					_account;
	UITextField*				_login;
	UITextField*				_password;
	UILabel*					_connecting;
	UIImageView*				_picture;
	UIImageView*				_pictureBorder;
	UIButton*					_button;
	UILabel*					_label;
}

- (id)initWithISAccount:(ISAccount*)a;

@end
