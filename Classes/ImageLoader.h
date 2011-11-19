//
//  ImageLoader.h
//  Vision
//
//  Created by Cédric Raud on 03/10/08.
//

#import <UIKit/UIKit.h>
#import "LoaderElement.h"


@interface ImageLoader : NSObject {
	NSMutableArray *_buffer;
	NSMutableDictionary *_dictionary;
	NSUInteger _active;
	NSUInteger _limit;
	NSUInteger _count;
	UIImage *placeholder;
	UIImage *contactBackground;
	UIImage *contactBackgroundOn;
	UIImage *loginBorder;
	UIImage *deleteContact;
	UIImage *deleteContactOn;
	UIImage *mailButton;
	UIImage *background;
}
@property(nonatomic, retain) UIImage *placeholder;
@property(nonatomic, retain) UIImage *contactBackground;
@property(nonatomic, retain) UIImage *contactBackgroundOn;
@property(nonatomic, retain) UIImage *loginBorder;
@property(nonatomic, retain) UIImage *deleteContact;
@property(nonatomic, retain) UIImage *deleteContactOn;
@property(nonatomic, retain) UIImage *mailButton;
@property(nonatomic, retain) UIImage *background;

-(id)init;

-(id)loadImageView:(UIImageView *)i withUrl:(NSString *)u;

-(void)free;

@end
