//
//  mainViewController.h
//  mapKit
//
//  Created by maliy on 12/31/10.
//  Copyright 2010 interMobile. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface mainViewController : UIViewController  <UIApplicationDelegate, MKMapViewDelegate,
					UISearchBarDelegate>
{
	MKMapView *mapView;
	UISearchBar *searchBar;
	
	BOOL keyboardShown;
}

@end
