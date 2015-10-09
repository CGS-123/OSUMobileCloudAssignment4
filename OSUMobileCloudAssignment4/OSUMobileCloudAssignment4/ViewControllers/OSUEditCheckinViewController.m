//
//  OSUEditCheckinViewController.m
//  OSUMobileCloudAssignment4
//
//  Created by Colin Smith on 8/13/15.
//  Copyright (c) 2015 Colin Smith. All rights reserved.
//

#import "OSUEditCheckinViewController.h"

@interface OSUEditCheckinViewController () <UITextFieldDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *editCheckinNameTextField;
@property (strong, nonatomic) NSString *updateName;

@end

@implementation OSUEditCheckinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.editCheckinNameTextField.delegate = self;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    self.updateName = newString;
    return YES;
}

- (IBAction)finishedButtonTapped:(id)sender {
    if (self.updateName) {
        [self.delegate editCheckinVC:self didDismissWithUpdatedString:self.updateName atIndex:self.index];
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
