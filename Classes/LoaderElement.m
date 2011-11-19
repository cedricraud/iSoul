//
//  LoaderElement.m
//  TF1Vision
//
//  Created by Cédric Raud on 22/10/08.
//

#import "LoaderElement.h"


@implementation LoaderElement

-(id) initWithImageView:(UIImageView *)i placeholder:(UIImage *)p dictionary:(NSMutableDictionary *)d andUrl:(NSString *)u
{
	if (i == nil)
		return nil;
	_imageView = [i retain];
	_url = [NSString stringWithString: u];
	_dictionary = d;
	_placeholder = p;
	_hasPlaceholder = NO;
	if (_imageView.image == nil)
	{
		[_placeholder retain];
		[_imageView setImage:_placeholder];
		_hasPlaceholder = YES;
	}
	return self;
}

-(void) subRun
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	if (_url == nil)
		return;
	//NSLog(@"Start %@", _url);
	NSURL *u = nil;
	NSData *imageData = nil;
	if ((u = [NSURL URLWithString:_url]))
		imageData = [[[NSData alloc]initWithContentsOfURL:u] retain];

	if (imageData && [imageData length] != 0)
	{
		[_dictionary setObject:imageData forKey:_url];

		UIImage *image = nil;
		if (!(image = [[[UIImage alloc] initWithData:imageData] retain]))
			return;

		[_imageView setImage:image];

		if (_imageView.image.size.width == 100)
			[_imageView setImage:_placeholder];

		if (_hasPlaceholder && _imageView.alpha == 1)
		{
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
		[_imageView setImage:[[UIImage alloc] initWithData:imageData]];
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
