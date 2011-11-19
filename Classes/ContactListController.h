//
//  ContactListController.h
//  iSoul
//
//  Created by Cédric Raud on 27/03/09.
//  Copyright 2009 Epita. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ISAccount.h"

@interface ContactListController : UIViewController<UITextFieldDelegate, UIScrollViewDelegate> {
	ISAccount *_account;

	UIScrollView *_scrollView;
	int _loadedContact;
	CGRect _listFrame;
	UIView *_addCell;
	UIButton *_addButton;
	UIImageView *_addPicture;
	UITextField *_addTextField;
	UIInterfaceOrientation _interfaceOrientation;
}
- (id)initWithISAccount:(ISAccount *)a;
- (int)getOffset;
- (void)reposition;

@end
