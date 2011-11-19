//
//  iSoulAppDelegate.h
//  iSoul
//
//  Created by Cédric Raud on 21/03/09.
//  Copyright Epita 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iSoulCore.h"
#import "NavController.h"
#import "LoginController.h"


@interface iSoulAppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow *window;
	ISAccount *_account;
	iSoulCore *_network;
	UIImageView *_backgroundView;

	LoginController *_loginController;

	NavController *_navController;
}
@property(nonatomic, retain) IBOutlet UIWindow *window;

@end
