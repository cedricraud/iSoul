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

- (id)initWithDate:(NSDate*)d content:(NSString*)c received:(bool)r
{
	date = [d retain];
	content = c;
	received = r;
	return self;
}

@end
