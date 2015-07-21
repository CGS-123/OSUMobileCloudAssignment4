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
#import <BZFoursquare.h>
#import <SVProgressHUD/SVProgressHUD.h>

static NSString *const kClientID = @"YBVF3NMUEF2FJNMN3QCUXQ0VMM0Z1OWG35FRKUPNN52CVFCO";
static NSString *const kCallbackURL = @"OSUMobileAssignment4";

@interface OSUMainScreenViewController () <BZFoursquareSessionDelegate, BZFoursquareRequestDelegate>

@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (nonatomic,strong) BZFoursquareRequest *request;
@property (nonatomic,copy) NSDictionary *meta;
@property (nonatomic,copy) NSArray *notifications;
@property (nonatomic,copy) NSDictionary *response;
@property (strong, nonatomic) UIWebView *webView;

@property (strong, nonatomic) CLLocation *currentLocation;

@end

@implementation OSUMainScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupMyFourSquare];
    if (![self.myFourSquare isSessionValid]) {
        [self.myFourSquare startAuthorization];
    }
    self.request = [[BZFoursquareRequest alloc] init];
    [self getLocation];
}

- (void)setupMyFourSquare {
    _myFourSquare = [[BZFoursquare alloc] initWithClientID:@"YBVF3NMUEF2FJNMN3QCUXQ0VMM0Z1OWG35FRKUPNN52CVFCO" callbackURL:@"OSUMobileAssignment4://foursquare"];
    _myFourSquare.sessionDelegate = self;
    _myFourSquare.locale = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
    _myFourSquare.version = @"20150720";
}

- (void)getLocation {
    __weak typeof(self) weakSelf = self;
    [[INTULocationManager sharedInstance] requestLocationWithDesiredAccuracy:INTULocationAccuracyCity
                                                                     timeout:40.0
                                                                       block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
                                                                           if (status == INTULocationServicesStateAvailable) {
                                                                               if (status == INTULocationStatusSuccess) {
                                                                                   self.currentLocation = currentLocation;
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

#pragma mark BZFoursquareRequestDelegate

- (void)requestDidFinishLoading:(BZFoursquareRequest *)request {
    self.meta = request.meta;
    self.notifications = request.notifications;
    self.response = request.response;
    self.request = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [SVProgressHUD dismiss];
}

- (void)request:(BZFoursquareRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"%s: %@", __PRETTY_FUNCTION__, error);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[error userInfo][@"errorDetail"] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
    [alertView show];
    self.meta = request.meta;
    self.notifications = request.notifications;
    self.response = request.response;
    self.request = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [SVProgressHUD dismiss];
}

#pragma mark -
#pragma mark BZFoursquareSessionDelegate

- (void)foursquareDidNotAuthorize:(BZFoursquare *)foursquare error:(NSDictionary *)errorInfo {
    NSLog(@"%s: %@", __PRETTY_FUNCTION__, errorInfo);
}

#pragma mark - Button Actions

- (IBAction)searchVenuesButtonPressed:(id)sender {
    [self searchVenues];
}

#pragma mark -
#pragma mark Anonymous category

- (void)cancelRequest {
    if (_request) {
        _request.delegate = nil;
        [_request cancel];
        self.request = nil;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [SVProgressHUD dismiss];
    }
}

- (void)prepareForRequest {
    [self cancelRequest];
    self.meta = nil;
    self.notifications = nil;
    self.response = nil;
}

- (void)searchVenues {
    [self prepareForRequest];
    NSString *latLongString = [NSString stringWithFormat:@"%f,%f", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude];
    NSDictionary *parameters = @{@"ll": latLongString};
    self.request = [self.myFourSquare requestWithPath:@"venues/search" HTTPMethod:@"GET" parameters:parameters delegate:self];
    [SVProgressHUD show];
    [_request start];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)checkin {
    [self prepareForRequest];
    NSDictionary *parameters = @{@"venueId": @"4d341a00306160fcf0fc6a88", @"broadcast": @"public"};
    self.request = [self.myFourSquare requestWithPath:@"checkins/add" HTTPMethod:@"POST" parameters:parameters delegate:self];
    [SVProgressHUD show];
    [_request start];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

-(BZFoursquareRequest *)request {
    if (!_request) {
        _request = [[BZFoursquareRequest alloc] init];
    }
    return _request;
}

@end
