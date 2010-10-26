//
//  marker.m
//  mapKit
//
//  Created by maliy on 7/27/10.
//  Copyright 2010 Andrey Derevyagin. All rights reserved.
//

#import "marker.h"


@interface marker ()
@property (nonatomic, retain) NSString *ttl;
@end


@implementation marker
@synthesize tag, ttl;

#pragma mark lifeCycle

- (id) initWithCoordinate2D:(CLLocationCoordinate2D) _coord
				   andTitle:(NSString *) title
{
	if (self = [super init])
	{
		coord = _coord;
		ttl = title;
	}
	return self;
}

- (void) dealloc
{
	self.ttl = nil;
	[super dealloc];
}

#pragma mark MKAnnotation 

- (CLLocationCoordinate2D) coordinate
{
	return coord;
}

- (NSString *) title
{
	return ttl;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
	coord = newCoordinate;
}

@end
