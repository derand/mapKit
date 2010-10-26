//
//  mapKitAppDelegate.m
//  mapKit
//
//  Created by maliy on 7/22/10.
//  Copyright 2010 Andrey Derevyagin. All rights reserved.
//

#import "mapKitAppDelegate.h"
#import "marker.h"

@implementation mapKitAppDelegate

@synthesize window;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
	MKMapView *mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
	
	// задаем участок карты, который показываем
	MKCoordinateRegion region;
	region.center.latitude     = 46.434917;
	region.center.longitude    = 30.727481;
	region.span.latitudeDelta  = 0.1;
	region.span.longitudeDelta = 0.1;
	
	// задаем точки пути
	CLLocationCoordinate2D mapCoords[6];
	mapCoords[ 0] = CLLocationCoordinate2DMake(46.476472, 30.704776);
	mapCoords[ 1] = CLLocationCoordinate2DMake(46.469664, 30.732229);
	mapCoords[ 2] = CLLocationCoordinate2DMake(46.462585, 30.750186);
	mapCoords[ 3] = CLLocationCoordinate2DMake(46.447197, 30.743040);
	mapCoords[ 4] = CLLocationCoordinate2DMake(46.415384, 30.723226);
	mapCoords[ 5] = CLLocationCoordinate2DMake(46.409143, 30.729909);
	
	// устанавливаем все
	MKPolyline *polyLine = [MKPolyline polylineWithCoordinates:mapCoords count:6];
	[mapView insertOverlay:polyLine atIndex:0];
	[mapView setDelegate:self];
	
	[mapView setRegion:region];
	
	marker *m = [[marker alloc] initWithCoordinate2D:CLLocationCoordinate2DMake(46.44370, 30.73639)
											andTitle:@"You can move this pin"];
	m.tag = 1;
	[mapView addAnnotation:m];
	[m release];
	
 	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	[window addSubview:mapView];
	
	[window makeKeyAndVisible];
	return YES;
}

#pragma mark MKMapViewDelegate
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    MKPolylineView *polylineView = [[[MKPolylineView alloc] initWithOverlay:overlay] autorelease];
    polylineView.strokeColor = [UIColor blueColor];
    polylineView.lineWidth = 3.0;
    return polylineView;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	MKAnnotationView *rv = nil;
	
	if ([(marker *)annotation tag]==1)
	{
		static NSString *aid = @"MARKER_ID";
		rv = [mapView dequeueReusableAnnotationViewWithIdentifier:aid];
		if (!rv)
		{
			rv = [[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:aid] autorelease];
		}
		rv.canShowCallout = YES;
		rv.draggable = YES;
		rv.image = [UIImage imageNamed:@"target.png"];
	}
	
	return rv;
}


#pragma mark -

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
	[window release];
	[super dealloc];
}


@end

