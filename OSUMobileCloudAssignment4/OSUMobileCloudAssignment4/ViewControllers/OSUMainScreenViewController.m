//
//  OSUMainScreenViewController.m
//  OSUMobileCloudAssignment4
//
//  Created by Colin Smith on 7/18/15.
//  Copyright (c) 2015 Colin Smith. All rights reserved.
//

#import "OSUMainScreenViewController.h"
#import "UIAlertController+Utils.h"
#import "SpecialFiles.h"
#import "OSUOnboardingPageViewController.h"
#import "OSUVenueTableViewCell.h"
#import "OSUEditCheckinViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <INTULocationManager/INTULocationManager.h>
#import <GoogleMaps/GoogleMaps.h>
#import <BZFoursquare.h>
#import <SVProgressHUD/SVProgressHUD.h>

static NSString *const kClientID = @"YBVF3NMUEF2FJNMN3QCUXQ0VMM0Z1OWG35FRKUPNN52CVFCO";
static NSString *const kCallbackURL = @"OSUMobileAssignment4";
static NSString *const kCellIdentifier = @"OSUVenueTableViewCell";

@interface OSUMainScreenViewController () <BZFoursquareSessionDelegate, BZFoursquareRequestDelegate, UITableViewDataSource, UITableViewDelegate, OSUEditCheckinVCDelegate>

@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (nonatomic,strong) BZFoursquareRequest *request;
@property (nonatomic,copy) NSDictionary *meta;
@property (nonatomic,copy) NSArray *notifications;
@property (nonatomic,copy) NSDictionary *response;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *venues;
@property (weak, nonatomic) IBOutlet UITextField *latitudeTextField;
@property (weak, nonatomic) IBOutlet UITextField *longitudeTextField;
@property (strong, nonatomic) NSString *currentVenue;
@property (weak, nonatomic) IBOutlet UITableView *checkinsTableview;
@property (strong, nonatomic) NSArray *checkins;
@property (strong, nonatomic) NSMutableArray *recentCheckins;
@property (strong, nonatomic) NSString  *currentUserID;
@property (weak, nonatomic) IBOutlet UITableView *recentCheckinsTableview;
@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;

@end

@implementation OSUMainScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupMyFourSquare];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.checkinsTableview.delegate = self;
    self.checkinsTableview.dataSource = self;
    self.recentCheckinsTableview.dataSource = self;
    self.recentCheckinsTableview.delegate = self;
    self.checkinsTableview.allowsSelection = NO;
    if (![self.myFourSquare isSessionValid]) {
        [self.myFourSquare startAuthorization];
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_settings"]
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(pushOnboarding)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(logOut)];
    self.request = [[BZFoursquareRequest alloc] init];
    [self.tableView registerNib:[UINib nibWithNibName:@"OSUVenueTableViewCell" bundle:nil] forCellReuseIdentifier:kCellIdentifier];
}

- (void)setupMyFourSquare {
    _myFourSquare = [[BZFoursquare alloc] initWithClientID:@"YBVF3NMUEF2FJNMN3QCUXQ0VMM0Z1OWG35FRKUPNN52CVFCO" callbackURL:@"OSUMobileAssignment4://foursquare"];
    _myFourSquare.sessionDelegate = self;
    _myFourSquare.locale = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
    _myFourSquare.version = @"20150720";
}

- (void) editCheckinVC:(OSUEditCheckinViewController *)productFilterViewController didDismissWithUpdatedString:(NSString *)updatedString atIndex:(NSInteger)index {
    [self.recentCheckins replaceObjectAtIndex:index withObject:updatedString];
    [self.recentCheckinsTableview reloadData];
    [[NSUserDefaults standardUserDefaults] setObject:self.recentCheckins forKey:self.currentUserID];
    [[NSUserDefaults standardUserDefaults] synchronize]; 
}


#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OSUVenueTableViewCell *venueTableViewCell = [self.tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if ([tableView isEqual:self.tableView]) {
        venueTableViewCell.nameLabel.text = self.venues[indexPath.row][@"name"];
    } else if ([tableView isEqual:self.recentCheckinsTableview]) {
        venueTableViewCell.nameLabel.text = self.recentCheckins[indexPath.row];
    } else {
        venueTableViewCell.nameLabel.text = self.checkins[indexPath.row][@"venue"][@"name"];
    }
    return venueTableViewCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:self.tableView]) {
        return self.venues.count;
    } else if ([tableView isEqual:self.recentCheckinsTableview]) {
        return self.recentCheckins.count;
    } else {
        return self.checkins.count;
    }
}

#pragma mark - UITableViewDelegate 

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:self.recentCheckinsTableview]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Choose an option." message:@"Delete to remove checkin, edit to edit the name or cancel" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"CANCEL" style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"EDIT" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            OSUEditCheckinViewController *editCheckinsVC = [[OSUEditCheckinViewController alloc] init];
            editCheckinsVC.delegate = self;
            editCheckinsVC.index = indexPath.row;
            [self.navigationController pushViewController:editCheckinsVC animated:YES];
            NSString *path = [NSString stringWithFormat:@"%@/user/%@", kBaseURL, self.currentUserID];
            NSDictionary *params = @{@"recent_checkins" : self.recentCheckins};
            [self.manager PUT:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"successfully update user checkins");
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"failed to update user checkins");
            }];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"DELETE" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self.recentCheckins removeObjectAtIndex:indexPath.row];
            NSString *path = [NSString stringWithFormat:@"%@/user/%@", kBaseURL, self.currentUserID];
            NSDictionary *params = @{@"recent_checkins" : self.recentCheckins};
            [self.manager PUT:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"successfully update user checkins");
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"failed to update user checkins");
            }];
            [[NSUserDefaults standardUserDefaults] setObject:self.recentCheckins forKey:self.currentUserID];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self.recentCheckinsTableview reloadData];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        self.currentVenue = self.venues[indexPath.row][@"id"];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Check in at this location?" message:@"Tap OK to check in at this venue." preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"CANCEL" style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self checkinWithCurrentVenue];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)pushOnboarding {
    OSUOnboardingPageViewController *onboardingVC = [[OSUOnboardingPageViewController alloc] init];
    [self.navigationController pushViewController:onboardingVC animated:YES];
}

- (void)logOut {
    [self.myFourSquare invalidateSession];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Login"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(login)];
    self.navigationItem.title = @"No Current User";
}

- (void)login {
    [self.myFourSquare startAuthorization];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(logOut)];
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

#pragma mark - BZFoursquareRequestDelegate

- (void)requestDidFinishLoading:(BZFoursquareRequest *)request {
    if ([request.path isEqualToString:@"checkins/add"]) {
        [self.recentCheckins addObject:request.response[@"checkin"][@"venue"][@"name"]];
        [[NSUserDefaults standardUserDefaults] setObject:self.recentCheckins forKey:self.currentUserID];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.recentCheckinsTableview reloadData];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Congrats %@, you successfully checked into %@",request.response[@"checkin"][@"user"][@"firstName"], request.response[@"checkin"][@"venue"][@"name"]] message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        [self searchRecentCheckins];
        [self presentViewController:alert animated:YES completion:nil];
    } else if ([request.path isEqualToString:@"users/self/checkins"]) {
        self.checkins = request.response[@"checkins"][@"items"];
        [self reloadTableViews];
    }  else if ([request.path isEqualToString:@"users/self"]) {
        NSString *thisUserID = request.response[@"user"][@"id"];
        self.currentUserID = thisUserID;
        self.recentCheckins = [[NSUserDefaults standardUserDefaults] objectForKey:self.currentUserID];
        self.navigationItem.title = [NSString stringWithFormat:@"Current User: %@", request.response[@"user"][@"firstName"]];
        [self.recentCheckinsTableview reloadData];
    } else {
        self.meta = request.meta;
        self.notifications = request.notifications;
        self.response = request.response;
        self.venues = request.response[@"venues"];
        self.request = nil;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [self reloadTableViews];
    }
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

#pragma mark - BZFoursquareSessionDelegate

- (void)foursquareDidNotAuthorize:(BZFoursquare *)foursquare error:(NSDictionary *)errorInfo {
    NSLog(@"%s: %@", __PRETTY_FUNCTION__, errorInfo);
}

- (void)foursquareDidAuthorize:(BZFoursquare *)foursquare {
    [self getUser];
    [self getLocation];
    NSString *path = [NSString stringWithFormat:@"%@/user", kBaseURL];
    if (self.currentUserID) {
        NSDictionary *params = @{@"id" : self.currentUserID};
        [self.manager POST:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSString *path = [NSString stringWithFormat:@"%@/user/%@", kBaseURL, self.currentUserID];
            [self.manager GET:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                self.recentCheckins = responseObject[@"recent_checkins"];
                NSLog(@"successfully update user checkins");
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"failed to update user checkins");
            }];
            NSLog(@"successfully created user");
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"failed to create user");
        }];
    }
}

#pragma mark - Button Actions

- (IBAction)searchVenuesButtonPressed:(id)sender {
    [self searchVenues];
}

- (IBAction)searchCustomLatLongButtonPressed:(id)sender {
    [self.longitudeTextField resignFirstResponder];
    [self.latitudeTextField resignFirstResponder];
    [self searchVenuesWithCustomLatLong];
}

- (IBAction)checkinsButtonPressed:(id)sender {
    [self searchRecentCheckins];
}

#pragma mark - Request

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
    [self createMapForLocationWithLongitude:self.currentLocation.coordinate.longitude andLatitude:self.currentLocation.coordinate.latitude];
    [SVProgressHUD show];
    [self.request start];
}

- (void)searchVenuesWithCustomLatLong {
    [self prepareForRequest];
    NSString *latLongString = [NSString stringWithFormat:@"%@,%@", self.latitudeTextField.text, self.longitudeTextField.text];
    NSDictionary *parameters = @{@"ll": latLongString};
    self.request = [self.myFourSquare requestWithPath:@"venues/search" HTTPMethod:@"GET" parameters:parameters delegate:self];
    [SVProgressHUD show];
    [self.request start];
    [self createMapForLocationWithLongitude:[self.longitudeTextField.text doubleValue] andLatitude:[self.latitudeTextField.text doubleValue]];
}

- (void)checkinWithCurrentVenue {
    [self searchRecentCheckins];
    [self prepareForRequest];
    NSString *path = [NSString stringWithFormat:@"%@/user/%@", kBaseURL, self.currentUserID];
    NSDictionary *params = @{@"recent_checkins" : self.recentCheckins};
    [self.manager PUT:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"successfully update user checkins");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failed to update user checkins");
    }];
    NSDictionary *parameters = @{@"venueId": self.currentVenue, @"broadcast": @"public"};
    self.request = [self.myFourSquare requestWithPath:@"checkins/add" HTTPMethod:@"POST" parameters:parameters delegate:self];
    [SVProgressHUD show];
    [_request start];
}

- (void)getUser {
    [self prepareForRequest];
    NSDictionary *parameters = @{@"limit": @"100"};
    self.request = [self.myFourSquare requestWithPath:@"users/self" HTTPMethod:@"GET" parameters:parameters delegate:self];
    [SVProgressHUD show];
    [_request start];
}

- (void)searchRecentCheckins {
    [self prepareForRequest];
     NSDictionary *parameters = @{@"limit": @"100"};
    self.request = [self.myFourSquare requestWithPath:@"users/self/checkins" HTTPMethod:@"GET" parameters:parameters delegate:self];
    [SVProgressHUD show];
    [_request start];
}

- (void)reloadTableViews {
    [self.tableView reloadData];
    [self.checkinsTableview reloadData];
}

- (BZFoursquareRequest *)request {
    if (!_request) {
        _request = [[BZFoursquareRequest alloc] init];
    }
    return _request;
}

- (NSMutableArray *)recentCheckins {
    if (!_recentCheckins) {
        _recentCheckins = [[NSMutableArray alloc] init];
    }
    return _recentCheckins;
}

@end
