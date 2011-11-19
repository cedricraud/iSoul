//
//  LoaderElement.m
//  TF1Vision
//
//  Created by Cédric Raud on 22/10/08.
//

#import "LoaderElement.h"


@implementation LoaderElement

- (id)initWithImageView:(UIImageView *)i placeholder:(UIImage *)p dictionary:(NSMutableDictionary *)d andUrl:(NSString *)u
{
	if ((self = [super init]) != nil) {
		if (i == nil) {
			[self release];
			return nil;
		}
		
		_imageView = [i retain];
		_url = [u copy];
		_dictionary = [d retain];
		_placeholder = [p retain];
		_hasPlaceholder = NO;
		if (_imageView.image == nil) {
			[_imageView setImage:_placeholder];
			_hasPlaceholder = YES;
		}
	}
	
	return self;
}

- (void)dealloc {
	[_imageView release];
	[_url release];
	[_dictionary release];
	[_placeholder release];
	
	[super dealloc];
}

- (void)subRun
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	if (_url == nil) return;
	
	//NSLog(@"Start %@", _url);
	NSURL *u = nil;
	NSData *imageData = nil;
	if ((u = [NSURL URLWithString:_url]))
		imageData = [NSData dataWithContentsOfURL:u];

	if (imageData.length > 0) {
		[_dictionary setObject:imageData forKey:_url];

		UIImage *image = [UIImage imageWithData:imageData];
		_imageView.image = image;

		if (_imageView.image.size.width == 100)
			_imageView.image = _placeholder;

		if (_hasPlaceholder && _imageView.alpha == 1) {
			_imageView.alpha = 0;
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:0.5];
			_imageView.alpha = 1;
			[UIView commitAnimations];
		}

	}
	//NSLog(@"End %@", _url);
	[pool drain];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"LEIsLoaded" object:self];
}

-(void) run
{
	NSData *imageData = [_dictionary objectForKey:_url];

	_imageView.alpha = 1;
	if (imageData != nil)
	{
		[_imageView setImage:[UIImage imageWithData:imageData]];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"LEIsLoaded" object:self];
	}
	else
		//[self subRun];
		[NSThread detachNewThreadSelector:@selector(subRun) toTarget:self withObject:nil];
/*		[NSTimer scheduledTimerWithTimeInterval: 0.1
										 target: self
									   selector: @selector(subRun)
									   userInfo: nil
										repeats: NO];*/
}

@end
