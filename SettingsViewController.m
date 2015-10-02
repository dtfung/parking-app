//
//  SettingsViewController.m
//  Parking
//
//  Created by Degerhan Deger on 5/11/15.
//  Copyright (c) 2015 DDCorp. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@property (nonatomic, strong) NSArray *settings;
@property (nonatomic, strong) NSArray *help;
@property (nonatomic, strong) NSArray *feedback;

@end

@implementation SettingsViewController

- (void)didReceiveMemoryWarning {[super didReceiveMemoryWarning];}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.settings = @[@"Voice Navigation Languages", @"Ditance Units", @"Parking Type", @"My Parking Spots", @"Auto-Lock Settings", @"Map Type"];
    self.help = @[@"Terms & Policy"];
    self.feedback = @[@"Drop a Line"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger sectionNumber = 0;
    switch (section) {
        case 0:
            sectionNumber = [_settings count];
            break;
            
        case 1:
            sectionNumber = [_help count];
            break;
            
        case 2:
            sectionNumber = [_feedback count];
            break;
            
        default:
            break;
    }
    return sectionNumber;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"settingsCell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"settingsCell"];
    }
    
    switch ([indexPath section]) {
        case 0:
            cell.textLabel.text = _settings[indexPath.row];
            break;
            
        case 1:
            cell.textLabel.text = _help[indexPath.row];
            break;
            
        case 2:
            cell.textLabel.text = _feedback[indexPath.row];
            break;
            
        default:
            break;
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *myString = @"Empty Setting";
    switch (section) {
        case 0:
            myString = @"Settings";
            break;
            
        case 1:
            myString = @"Help";
            break;

        case 2:
            myString = @"Feedback";
            break;
            
        default:
            break;
    }
    
    return myString;
}


@end
