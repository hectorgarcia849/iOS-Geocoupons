//
//  ViewController.m
//  geocoupons
//
//  Created by Hector Garcia on 2016-12-10.
//  Copyright © 2016 Hector Garcia. All rights reserved.
//

@import MapKit;
#import "ViewController.h"

@interface ViewController () <MKMapViewDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;//keeps track of all our location services
@property (nonatomic, assign) BOOL mapIsMoving;
@property (strong, nonatomic) MKPointAnnotation *currentAnno;
@property (strong, nonatomic) CLCircularRegion *geoRegion;
@property (strong, nonatomic) MKPointAnnotation *bizAnno;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //setup locationManger
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self; //requires that this class be a delegate.  It will send messages to the ViewController.  Based on messages from delegating obj (locationManager), we can update the VC.
    self.locationManager.allowsBackgroundLocationUpdates = YES;
    self.locationManager.pausesLocationUpdatesAutomatically = YES;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 3;
    
    //zoom the map very close
    CLLocationCoordinate2D noLocation;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(noLocation, 500, 500); //500by500
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits: viewRegion]; //fits into device aspect ratio
    [self.mapView setRegion:adjustedRegion animated: YES]; //executes zoom based on params given above
    
    //current location, create georegion object, add annotation for business
    [self addCurrentAnnotation];
    [self setUpGeoRegion];
    [self addBizAnnotation];
    
    
    self.mapView.showsUserLocation = YES; //blue dot
    [self.locationManager startUpdatingLocation];
    [self.locationManager startMonitoringForRegion:self.geoRegion]; //stores region in the monitoredRegions
    [self.locationManager performSelector:@selector(requestStateForRegion:) withObject:self.geoRegion afterDelay:1];
    
    //verify permissions given for location services
    if([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]] == YES) {
        
        //first check, if no location, ask for permission .
        
        CLAuthorizationStatus currentStatus = [CLLocationManager authorizationStatus];
        if((currentStatus != kCLAuthorizationStatusAuthorizedWhenInUse) ||
           (currentStatus != kCLAuthorizationStatusAuthorizedAlways)){
            [self.locationManager requestAlwaysAuthorization];
        }
    }
    
    //second check, ask for notification permissions if the app is in the background
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert; //one we really need is alert
    
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil]; //ask for those notifications
    [[UIApplication sharedApplication] registerUserNotificationSettings: mySettings];

    
    
    
    //[self.locationManager startMonitoringSignificantLocationChanges];

}

//first, note that we we connected the MapView to the ViewController, delegating obj: MV, delegate obj: VC.  In this way we made the VC capable of receiving messages from a MKMap obj with <MKMapViewDelegate>.  The actual delegation occurs in the mainstory board by control clicking mapView and dragging it to VC. After this, now we can write callback methods.  This means, when there are changes in the mapView, it will send a message to the VC allowing it to update other objects.

//mapView methods are implemented inteface methods

-(void) mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    self.mapIsMoving = YES;
}

-(void) mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    self.mapIsMoving = NO;
}

- (void) addCurrentAnnotation {
    self.currentAnno = [[MKPointAnnotation alloc] init];
    self.currentAnno.coordinate = CLLocationCoordinate2DMake(0.0, 0.0);
    self.currentAnno.title = @"My Location";
}

- (void) addBizAnnotation {
    self.bizAnno = [[MKPointAnnotation alloc]init];
    self.bizAnno.coordinate = CLLocationCoordinate2DMake(43.652624,-79.472997);
    self.bizAnno.title = @"Magic Spells Inc.";
    [self.mapView addAnnotation: self.bizAnno];
    [self.mapView selectAnnotation:self.bizAnno animated:YES];
    
}

- (void) centerMap: (MKPointAnnotation *) centerPoint {
    [self.mapView setCenterCoordinate:centerPoint.coordinate animated: YES];
}

- (void) setUpGeoRegion {
    //create the geographic region to be monitored
    self.geoRegion = [[CLCircularRegion alloc]
                      initWithCenter:CLLocationCoordinate2DMake(43.652624,-79.472997)
                      radius:100
                      identifier: @"MyRegionIndentifier"];
}


#pragma - location call backs

//when location updated, this function will be called.
- (void) locationManger:(CLLocationManager *)manager didDetermineState: (CLRegionState)state for:(CLRegion *)region {
    if(state == CLRegionStateUnknown) {
        NSLog(@"Region: Unknown");
    }else if(state == CLRegionStateInside) {
        NSLog(@"Region: Inside");
    }else if(state == CLRegionStateOutside) {
        NSLog(@"Region: Outside");
    }else {
        NSLog(@"Region: Mystery");
    }
}


- (void) locationManager: (CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    self.currentAnno.coordinate = locations.lastObject.coordinate;
    if(self.mapIsMoving == NO) {
        [self centerMap: self.currentAnno]; //center map on current annotation
    }
}

- (void) locationManager: (CLLocationManager *)manager didEnterRegion:(nonnull CLRegion *)region {
    UILocalNotification *note = [[UILocalNotification alloc] init];
    note.fireDate = [NSDate dateWithTimeIntervalSinceNow:10];
    note.repeatInterval = 0;
    note.alertTitle = @"Sales Alert!";
    int discount = 10;
    note.alertBody = [NSString stringWithFormat:@"Magic Spells Inc. Get %2d%% OFF all spells for the next 30 minutes! USE CODE: GEOREGIONSROCK", discount];
    note.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
    note.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:note];
}

- (void) locationManager: (CLLocationManager *)manager didExitRegion:(nonnull CLRegion *)region {
    UILocalNotification *note = [[UILocalNotification alloc] init];
    note.fireDate = nil;
    note.repeatInterval = 0;
    note.alertTitle = @"Sales Alert!";
    note.alertBody = [NSString stringWithFormat:@"We hope you stop by our neighbourhood again soon!"];
    note.soundName = UILocalNotificationDefaultSoundName;
    //[[UIApplication sharedApplication] scheduleLocalNotification:note];
}

- (void) locationManager: (CLLocationManager *)manager didStartMonitoringForRegion: (nonnull CLRegion *)region {
    UILocalNotification *note = [[UILocalNotification alloc] init];
    note.fireDate = nil;
    note.repeatInterval = 0;
    note.alertTitle = @"Region Monitoring Started";
    note.alertBody = [NSString stringWithFormat: @"Region Monitoring Started..."];
    note.soundName = UILocalNotificationDefaultSoundName;
    //[[UIApplication sharedApplication] scheduleLocalNotification:note];
}

- (void) locationManager: (CLLocationManager *)manager monitoringDidFailForRegion: (CLRegion *) region withError: (NSError *)error {
    UILocalNotification *note = [[UILocalNotification alloc] init];
    note.fireDate = nil;
    note.repeatInterval = 0;
    note.alertTitle = @"Region Monitoring DID NOT Start";
    note.alertBody = [NSString stringWithFormat: @"Region Monitoring NOT Started..."];
    note.soundName = UILocalNotificationDefaultSoundName;
    //[[UIApplication sharedApplication] scheduleLocalNotification:note];

}

@end
