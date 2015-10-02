//
//  ErrorScreenViewController.m
//  Parking
//
//  Created by Aditya Narayan on 5/8/15.
//  Copyright (c) 2015 DDCorp. All rights reserved.
//

#import "ErrorScreenViewController.h"

@interface ErrorScreenViewController ()

@end

@implementation ErrorScreenViewController
static BOOL isUpdated = NO;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _errorLabel.text = self.error;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)refreshApplication:(UIButton *)sender {
    isUpdated = NO;
    [self.errorLabel setText:@"Updating"];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    UIViewController *mainViewController;
    
    NSURLResponse *response;
    NSError *error;
    [self animateRotationFor:sender];
    [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://google.com"]] returningResponse:&response error:&error];
    
    if (!error) {
        mainViewController = [storyboard instantiateViewControllerWithIdentifier:@"MainNavigationVC"];
        [self presentViewController:mainViewController animated:YES completion:nil];
    }
    [self.errorLabel setText:error.localizedDescription];
    isUpdated = YES;
}

- (void)animateRotationFor:(UIButton *)button
{
    CGAffineTransform rotationTransform = CGAffineTransformRotate(button.transform, M_PI);
    
    [UIView animateWithDuration:1.5 animations:^{
        button.transform = rotationTransform;
    } completion:^(BOOL finished) {
        if (finished && !isUpdated) [self animateRotationFor:button];
    }];
}




@end
