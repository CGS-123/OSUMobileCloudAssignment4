//
//  OSUOnboardingPageViewController.m
//  OSUMobileCloudAssignment4
//
//  Created by Colin Smith on 7/21/15.
//  Copyright (c) 2015 Colin Smith. All rights reserved.
//

#import "OSUOnboardingPageViewController.h"

@interface OSUOnboardingPageViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation OSUOnboardingPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidLayoutSubviews {
    CGRect newFrame = self.view.frame;
    newFrame.size.height = 931;
    self.scrollView.frame = newFrame;
    self.scrollView.contentSize = newFrame.size;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
