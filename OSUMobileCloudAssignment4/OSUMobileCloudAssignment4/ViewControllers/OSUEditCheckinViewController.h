//
//  OSUEditCheckinViewController.h
//  OSUMobileCloudAssignment4
//
//  Created by Colin Smith on 8/13/15.
//  Copyright (c) 2015 Colin Smith. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OSUEditCheckinVCDelegate;

@interface OSUEditCheckinViewController : UIViewController

@property (weak, nonatomic) id<OSUEditCheckinVCDelegate> delegate;
@property (nonatomic) NSInteger index;

@end

@protocol OSUEditCheckinVCDelegate <NSObject>

- (void) editCheckinVC:(OSUEditCheckinViewController *)productFilterViewController didDismissWithUpdatedString:(NSString *)updatedString atIndex:(NSInteger)index;

@end