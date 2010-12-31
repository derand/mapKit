    //
//  mainViewController.m
//  mapKit
//
//  Created by maliy on 12/31/10.
//  Copyright 2010 interMobile. All rights reserved.
//

#import "mainViewController.h"
#import "marker.h"

@interface mainViewController()
@property (nonatomic, retain) UISearchBar *searchBar;
@property (nonatomic, retain) MKMapView *mapView;

- (void) searchAddress:(NSString *) address;
@end


@implementation mainViewController
@synthesize searchBar, mapView;


#pragma mark -

- (NSString *) convertChars:(NSString *) str
{
	NSMutableString *rv = [str mutableCopy];
	
	[rv replaceOccurrencesOfString:@" "
						withString:@"+"
						   options:0
							 range:NSMakeRange(0, [rv length])];
	[rv replaceOccurrencesOfString:@","
						withString:@""
						   options:0
							 range:NSMakeRange(0, [rv length])];
	[rv replaceOccurrencesOfString:@"."
						withString:@""
						   options:0
							 range:NSMakeRange(0, [rv length])];
	
    return [rv autorelease];
}

- (NSString *) getAttr:(NSString *) attr fromString:(NSString *) str
{
	NSString *rv = nil;
	NSRange rng = [str rangeOfString:[NSString stringWithFormat:@"\"%@\":", attr]];
	if (rng.location != NSNotFound)
	{
		rng.location = rng.location +rng.length;
		rng.length = 0;
		unichar ch = [str characterAtIndex:rng.location+rng.length];
		while ((rng.location+rng.length)<[str length] && (ch!=',' && ch!='}'))
		{
			rng.length++;
			ch = [str characterAtIndex:rng.location+rng.length]; 
		}
		rv = [str substringWithRange:rng];
	}
	return rv;
}

- (void) searchAddress:(NSString *) address
{
	NSError *err = nil;
	NSString *url = [NSString stringWithFormat:@"http://api.maps.yahoo.com/ajax/geocode?appid=onestep&qt=1&id=m&qs=%@",
					 [self convertChars:address]];
	NSString *str = [NSString stringWithContentsOfURL:[NSURL URLWithString:url]
											 encoding:NSUTF8StringEncoding
												error:&err];
	NSLog(@"%@", str);
	CGFloat lat = [[self getAttr:@"Lat"  fromString:str] floatValue];
	CGFloat lon = [[self getAttr:@"Lon"  fromString:str] floatValue];
	if (fabs(lat)>.0001 || fabs(lon)>.0001)
	{
		MKCoordinateRegion region;
		region.center.latitude     = lat;
		region.center.longitude    = lon;
		region.span.latitudeDelta  = 0.1;
		region.span.longitudeDelta = 0.1;
		
		[mapView setRegion:region];
	}
}


#pragma mark MKMapViewDelegate
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    MKPolylineView *polylineView = [[[MKPolylineView alloc] initWithOverlay:overlay] autorelease];
    polylineView.strokeColor = [UIColor blueColor];
    polylineView.lineWidth = 3.0;
    return polylineView;
}

- (MKAnnotationView *)mapView:(MKMapView *)_mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	MKAnnotationView *rv = nil;
	
	if ([(marker *)annotation tag]==1)
	{
		static NSString *aid = @"MARKER_ID";
		rv = [_mapView dequeueReusableAnnotationViewWithIdentifier:aid];
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


#pragma mark UISearchBarDelegate
- (BOOL) searchBarShouldBeginEditing:(UISearchBar *) _searchBar
{
	return YES;
}

- (void) searchBarCancelButtonClicked:(UISearchBar *) _searchBar
{
	searchBar.text = nil;
	[searchBar resignFirstResponder];
}

- (void) searchBarSearchButtonClicked:(UISearchBar *) _searchBar
{
	[self searchAddress:_searchBar.text];
	[searchBar resignFirstResponder];
}


#pragma mark keyboard notifications

- (void) keyboardWillShown:(NSNotification*) aNotification
{
	if (keyboardShown)
		return;
	
	NSDictionary* info = [aNotification userInfo];
	NSLog(@"%@", info);
	
	// Get the size of the keyboard.
	NSValue* aValue = [info objectForKey:UIKeyboardBoundsUserInfoKey];
	if (!aValue)
	{
		aValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
	}
	CGSize keyboardSize = [aValue CGRectValue].size;
	
	CGRect rct = self.view.bounds;
	CGFloat kHeight = MIN(keyboardSize.width, keyboardSize.height);
	rct.origin.y = searchBar.frame.size.height;
	rct.size.height -= kHeight-self.navigationController.navigationBar.frame.size.height-searchBar.frame.size.height;
	
//	[self.navigationController setNavigationBarHidden:YES animated:YES];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	searchBar.showsCancelButton = YES;
	mapView.frame = rct;
	[UIView commitAnimations];
	
	keyboardShown = YES;
}

- (void) keyboardDidShown:(NSNotification*) aNotification
{
}

- (void)keyboardWasHidden:(NSNotification*)aNotification
{
	CGRect rct = self.view.bounds;
	if (keyboardShown)
	{
		rct.size.height -= self.navigationController.navigationBar.frame.size.height;
	}
	rct.origin.y += searchBar.frame.size.height;
	rct.size.height -= searchBar.frame.size.height;
		
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	searchBar.showsCancelButton = NO;
	mapView.frame = rct;
	[UIView commitAnimations];
	
	keyboardShown = NO;
}

- (void) registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillShown:)
												 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardDidShown:)
												 name:UIKeyboardDidShowNotification object:nil];
	
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWasHidden:)
												 name:UIKeyboardDidHideNotification object:nil];
}

- (void) unRegisterForKeyboardNotifications
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[searchBar resignFirstResponder];
	[self keyboardWasHidden:nil];
}

#pragma mark -

- (void) viewDidAppear:(BOOL) animated
{
	[self registerForKeyboardNotifications];
	
	[self keyboardWasHidden:nil];
}

- (void) viewDidDisappear:(BOOL) animated
{
	[self unRegisterForKeyboardNotifications];
}


// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void) loadView
{
	[super loadView];
	
//	[self initNavigationBar];
	
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	
	// setup our parent content view and embed it to your view controller
	UIView *contentView = [[UIView alloc] initWithFrame:screenRect];
	contentView.backgroundColor = [UIColor whiteColor];
	contentView.autoresizesSubviews = YES;
	contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	self.view = contentView;
	[contentView release];
	
	CGRect rct;

//	[UISearchField defaultHeight];
	searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, screenRect.size.width, 44.0)];
	searchBar.delegate = self;
	searchBar.showsCancelButton = NO;
	searchBar.barStyle = UIBarStyleBlackTranslucent;
	searchBar.placeholder = NSLocalizedString(@"Enter address", @"");
	[self.view addSubview:searchBar];

	rct = self.view.bounds;
	rct.origin.y += searchBar.frame.size.height;
	rct.size.height -= searchBar.frame.size.height;

	mapView = [[MKMapView alloc] initWithFrame:rct];
	
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

	[self.view addSubview:mapView];

	keyboardShown = NO;
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	
	self.searchBar = nil;
	self.mapView = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
