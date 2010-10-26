//
//  mapKitAppDelegate.h
//  mapKit
//
//  Created by maliy on 7/22/10.
//  Copyright 2010 Andrey Derevyagin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface mapKitAppDelegate : NSObject <UIApplicationDelegate, MKMapViewDelegate>
{
    UIWindow *window;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end

