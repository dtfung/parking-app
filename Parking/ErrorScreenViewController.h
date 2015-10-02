//
//  ErrorScreenViewController.h
//  Parking
//
//  Created by Aditya Narayan on 5/8/15.
//  Copyright (c) 2015 DDCorp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ErrorScreenViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (nonatomic, copy) NSString *error;

@end
