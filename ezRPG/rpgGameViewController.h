//
//  rpgGameViewController.h
//  ezRPG
//
//  Created by Elie Zananiri on 2014-03-07.
//  Copyright (c) 2014 silentlyCrashing::net. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface rpgGameViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *questionLabel;
@property (weak, nonatomic) IBOutlet UIButton *yesButton;
@property (weak, nonatomic) IBOutlet UIButton *noButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

- (IBAction)yesSelected:(id)sender;
- (IBAction)noSelected:(id)sender;
- (IBAction)doneSelected:(id)sender;

@end
