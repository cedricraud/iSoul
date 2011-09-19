//
//  Contact.h
//  iSoul
//
//  Created by Cédric Raud on 27/03/09.
//  Copyright 2009 Epita. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageLoader.h"

#define PICTURL @"http://www.epitech.net/intra/photo.php?login=%@"
#define NOLOGIN @"login_x"
#define CONTACT_HEIGHT 60


@interface Contact : NSObject {
	NSString*				login;
	NSString*				name;
	NSString*				status;
	NSString*				location;
	NSString*				userdata;
	NSMutableArray*			messages;
	int						unread;
	Boolean					root;
	
	UIImageView*			_statusImageView;
	UIImageView*			_picture;
	UIImageView*			_pictureBorder;
	UIButton*				_button;
	UIButton*				_deleteButton;
	UIButton*				_mailButton;
	UILabel*				_nameLabel;
	UILabel*				_locationLabel;
	UILabel*				_unreadLabel;
    UIView*					view;
	ImageLoader*			_imageLoader;
	UIInterfaceOrientation	_interfaceOrientation;
}

@property (nonatomic, retain) NSString*				login;
@property (nonatomic, retain) NSString*				status;
@property (nonatomic, retain) NSString*				location;
@property (nonatomic, retain) NSString*				userdata;
@property (nonatomic, retain) UIView*				view;
@property (nonatomic, retain) NSMutableArray*		messages;
@property					  int					unread;
@property					  Boolean				root;


- (id)initWithLogin:(NSString*)l imageLoader:(ImageLoader*)i;
- (id)updateWithLogin:(NSString*)l;
- (void)setOrientation:(UIInterfaceOrientation)orientation;
- (void)loadPicture;

@end
