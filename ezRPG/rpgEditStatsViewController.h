//
//  rpgEditStatsViewController.h
//  ezRPG
//
//  Created by Elie Zananiri on 2014-03-06.
//  Copyright (c) 2014 silentlyCrashing::net. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "rpgQuestion.h"
#import "rpgToken.h"

@interface rpgEditStatsViewController : UITableViewController

@property (assign, nonatomic, getter = isEditingTokens, setter = setEditingTokens:) BOOL bEditingTokens;

@property (strong, nonatomic) rpgQuestion *question;
@property (strong, nonatomic) rpgToken *token;

- (IBAction)editItem:(id)sender;

@end
