//
//  ImageSelector.m
//  Vision
//
//  Created by Cédric Raud on 03/10/08.
//

#import "ImageLoader.h"


@implementation ImageLoader

@synthesize placeholder, contactBackground, contactBackgroundOn, loginBorder, deleteContact, deleteContactOn, mailButton, background;

- (id)init
{
	if ((self = [super init]) != nil) {
		_buffer = [[NSMutableArray alloc] init];
		_dictionary = [[NSMutableDictionary alloc] init];
		_active = 0;
		_limit = 10;
		_count = 0;
		placeholder = [[UIImage imageNamed:@"placeholder.png"] retain];
		contactBackground = [[UIImage imageNamed:@"contact-background.png"] retain];
		contactBackground = [contactBackground stretchableImageWithLeftCapWidth:10 topCapHeight:10];
		contactBackgroundOn = [[UIImage imageNamed:@"contact-background-on.png"] retain];
		contactBackgroundOn = [contactBackgroundOn stretchableImageWithLeftCapWidth:10 topCapHeight:10];
		loginBorder = [[UIImage imageNamed:@"login-border.png"] retain];
		deleteContact = [[UIImage imageNamed:@"delete-contact.png"] retain];
		deleteContactOn = [[UIImage imageNamed:@"delete-contact-on.png"] retain];
		mailButton = [[UIImage imageNamed:@"mail-button.png"] retain];
		background = [[UIImage imageNamed:@"background.png"] retain];

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadedItem:) name:@"LEIsLoaded" object:nil];
	}

	return self;
}

- (void)dealloc
{
	[_buffer release];
	[_dictionary release];
	[placeholder release];
	[contactBackground release];
	[contactBackgroundOn release];
	[loginBorder release];
	[deleteContact release];
	[deleteContactOn release];
	[mailButton release];
	[background release];
	
	[super dealloc];
}

- (void)run
{
	LoaderElement *le;
	while ([_buffer count] > 0 && _active < _limit)
	{
		le = [_buffer objectAtIndex:0];
		[_buffer removeObjectAtIndex:0];
		if (le)
			[le run];
		_active++;
	}
}

- (void)loadedItem:(NSNotification *)notification
{
	_count++;
	_active--;

	/*NSTimer *timer = nil;
	timer = [NSTimer scheduledTimerWithTimeInterval: 0.2
											 target: self
										   selector: @selector(run:)
										   userInfo: nil
											repeats: NO];	*/
	[self run];
}

- (id)loadImageView:(UIImageView *)i withUrl:(NSString *)u
{
	LoaderElement *e = [[[LoaderElement alloc] initWithImageView:i placeholder:placeholder dictionary:_dictionary andUrl:u] autorelease];
	if (e) {
		[_buffer addObject:e];
		[self run];
	}

	return self;
}

- (void)didReceiveMemoryWarning
{
	NSLog(@"ImageLoader didReceiveMemoryWarning : Omagad !");
	[_dictionary removeAllObjects];
}

- (void)free
{
	[placeholder release];
	[_dictionary removeAllObjects];
}


@end
