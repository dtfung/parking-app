//
//  CustomSegue.m
//  Parking
//
//  Created by Degerhan Deger on 5/7/15.
//  Copyright (c) 2015 DDCorp. All rights reserved.
//

#import "CustomSegue.h"

@implementation CustomSegue

- (void)perform {
    __block UIViewController *sourceViewController = (UIViewController *)[self sourceViewController];
    __block UIViewController *destinationController = (UIViewController *)[self destinationViewController];
    
    CATransition* transition = [CATransition animation];
    transition.duration = 0.1;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade; //kCATransitionMoveIn; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
    transition.subtype = kCATransitionFromTop; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom
    
    [sourceViewController.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    [sourceViewController.navigationController pushViewController:destinationController animated:NO];
}

@end
