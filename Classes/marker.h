//
//  marker.h
//  mapKit
//
//  Created by maliy on 7/27/10.
//  Copyright 2010 Andrey Derevyagin. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface marker : NSObject <MKAnnotation>
{
	CLLocationCoordinate2D coord;
	NSInteger tag;
	NSString *ttl;
}

@property (nonatomic, assign) NSInteger tag;

- (id) initWithCoordinate2D:(CLLocationCoordinate2D) _coord
				   andTitle:(NSString *) title;

@end
