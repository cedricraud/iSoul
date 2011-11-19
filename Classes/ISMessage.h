//
// ISMessageh
//  iSoul
//
//  Created by Cédric Raud on 06/06/09.
//  Copyright 2009 Epita. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ISMessage: NSObject {
	BOOL received;
	NSDate *date;
	NSString *content;
}
@property(nonatomic, assign) BOOL received;
@property(nonatomic, retain) NSDate *date;
@property(nonatomic, retain) NSString *content;

- (id)initWithDate:(NSDate *)d content:(NSString *)c received:(bool)r;

@end
