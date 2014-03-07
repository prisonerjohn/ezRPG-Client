//
//  rpgAdminViewController.h
//  ezRPG
//
//  Created by Elie Zananiri on 2014-03-05.
//  Copyright (c) 2014 silentlyCrashing::net. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface rpgAdminViewController : UIViewController

@property (assign, nonatomic, getter = isEditingTokens, setter = setEditingTokens:) BOOL bEditingTokens;

- (IBAction)editTokens:(id)sender;
- (IBAction)editQuestions:(id)sender;

@end
