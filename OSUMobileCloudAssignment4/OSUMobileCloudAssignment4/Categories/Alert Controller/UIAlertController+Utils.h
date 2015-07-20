//
//  UIAlertController+Utils.h
//  cobrain-ios
//
//  Created by Colin Smith on 7/2/15.
//  Copyright (c) 2015 Cobrain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (Utils)

+ (UIAlertController *)basicAlertWithTitle:(NSString *)title message:(NSString *)message;
+ (UIAlertController *)basicAlertWithError:(NSError *)error;
+ (UIAlertController *)basicAlertForMallsErrorLocation;
+ (UIAlertController *)enableLocationServicesAlert;
+ (UIAlertController *)aisleModificationAlert;
+ (UIAlertController *)aisleCreationFailed;
+ (UIAlertController *)noInternetConnection;
+ (UIAlertController *)aisleSizePriceRetrievalFailed;

@end
