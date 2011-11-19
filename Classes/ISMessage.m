//
// ISMessagem
//  iSoul
//
//  Created by Cédric Raud on 06/06/09.
//  Copyright 2009 Epita. All rights reserved.
//

#import "ISMessage.h"


@implementation ISMessage

@synthesize received, date, content;

- (id)initWithDate:(NSDate *)d content:(NSString *)c received:(bool)r
{
	if ((self = [super init]) != nil) {
		date = [d retain];
		content = [c copy];
		received = r;
	}
	
	return self;
}

- (void)dealloc
{
	[date release];
	[content release];
	
	[super dealloc];
}

@end
