//
//  OSUMainScreenViewController.m
//  OSUMobileCloudAssignment4
//
//  Created by Colin Smith on 7/18/15.
//  Copyright (c) 2015 Colin Smith. All rights reserved.
//

#import "OSUMainScreenViewController.h"
#import "UIAlertController+Utils.h"
#import <INTULocationManager/INTULocationManager.h>
#import <GoogleMaps/GoogleMaps.h>

@interface OSUMainScreenViewController ()

@property (weak, nonatomic) IBOutlet GMSMapView *mapView;

@end

@implementation OSUMainScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getLocation];
}

- (void)getLocation {
    __weak typeof(self) weakSelf = self;
    [[INTULocationManager sharedInstance] requestLocationWithDesiredAccuracy:INTULocationAccuracyCity
                                                                     timeout:40.0
                                                                       block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
                                                                           if (status == INTULocationServicesStateAvailable) {
                                                                               if (status == INTULocationStatusSuccess) {
                                                                                   [weakSelf createMapForLocationWithLongitude:currentLocation.coordinate.longitude andLatitude:currentLocation.coordinate.latitude];
                                                                               }
                                                                               else if (status == INTULocationStatusTimedOut) {
                                                                                   UIAlertController *alertController = [UIAlertController basicAlertForMallsErrorLocation];
                                                                                   [self presentViewController:alertController animated:YES completion:nil];
                                                                               }
                                                                               else {
                                                                                   UIAlertController *alertController = [UIAlertController basicAlertForMallsErrorLocation];
                                                                                   [self presentViewController:alertController animated:YES completion:nil];
                                                                               }
                                                                           } else {
                                                                               UIAlertController *alertController = [UIAlertController enableLocationServicesAlert];
                                                                               [self presentViewController:alertController animated:YES completion:nil];
                                                                           }
                                                                       }];
}

- (void)createMapForLocationWithLongitude:(CLLocationDegrees)longitude andLatitude:(CLLocationDegrees)latitude {
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:latitude
                                                            longitude:longitude
                                                                 zoom:6];
    self.mapView.camera = camera;
    self.mapView.myLocationEnabled = YES;
    
    // Creates a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(latitude, longitude);
    marker.title = @"Your Location";
    marker.snippet = @"Right?";
    marker.map = self.mapView;
}

@end
