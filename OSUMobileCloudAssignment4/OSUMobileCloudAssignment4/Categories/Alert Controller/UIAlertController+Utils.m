//
//  UIAlertController+Utils.h
//  cobrain-ios
//
//  Created by Colin Smith on 7/2/15.
//  Copyright (c) 2015 Cobrain. All rights reserved..
//

#import "UIAlertController+Utils.h"

@implementation UIAlertController (Utils)

+ (UIAlertController *)basicAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleCancel handler:nil]];
    return alert;
}

+ (UIAlertController *)basicAlertWithError:(NSError *)error {
    return [self basicAlertWithTitle:nil message:error.localizedDescription];
}

+ (UIAlertController *)basicAlertForMallsErrorLocation {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Location error" message:@"Unable to get location" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleCancel handler:nil]];
    return alert;
}

+ (UIAlertController *)enableLocationServicesAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Location services disabled" message:@"Please go to Location Services within the Privacy section in Settings to enable location for the Cobrain app." preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleCancel handler:nil]];
    return alert;
}

+ (UIAlertController *)aisleModificationAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"These selections will override your existing rack preferences. Do you still want to save?" preferredStyle:UIAlertControllerStyleAlert];
    return alert;
}

+ (UIAlertController *)noInternetConnection {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Internet Connection" message:@"Please ensure that you are connected to the Internet" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleCancel handler:nil]];
    return alert;
}

+ (UIAlertController *)aisleCreationFailed {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Could not create a rack at this time" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleCancel handler:nil]];
    return alert;
}

+ (UIAlertController *)aisleSizePriceRetrievalFailed {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Unable to retreive sizes and prices. Please skip selecting these for now, as you will be able to edit your rank later" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleCancel handler:nil]];
    return alert;
}

@end
