//
//  ContactTableViewController.h
//  iSoul
//
//  Created by Cédric Raud on 27/03/09.
//  Copyright 2009 Epita. All rights reserved.
//

#import <UIKit/UIKit.h>

#import	"ISAccount.h"

@interface ContactTableViewController : UITableViewController<UITextFieldDelegate> {
	ISAccount *_account;
	UITableViewCell *_addCell;
	UIButton *_addPicture;
	UILabel *_addLabel;
	UITextField *_addTextField;
	CGRect _frame;
}
- (id)initWithStyle:(UITableViewStyle)style account:(ISAccount *)a;

@end
