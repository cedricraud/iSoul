//
//  LoaderElement.h
//  TF1Vision
//
//  Created by Cédric Raud on 22/10/08.
//

#import <UIKit/UIKit.h>


@interface LoaderElement : NSObject {
	UIImageView *_imageView;
	NSString *_url;
	NSMutableDictionary *_dictionary;
	UIImage *_placeholder;
	BOOL _hasPlaceholder;
}

-(id) initWithImageView:(UIImageView *)i placeholder:(UIImage *)p dictionary:(NSMutableDictionary *)d andUrl:(NSString *)u;
-(void) run;

@end
