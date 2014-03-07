//
//  rpgEditItemsViewController.h
//  ezRPG
//
//  Created by Elie Zananiri on 2014-03-06.
//  Copyright (c) 2014 silentlyCrashing::net. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTokenCellIdentifier    @"TokenCell"
#define kQuestionCellIdentifier @"QuestionCell"

@interface rpgEditItemsViewController : UITableViewController

@property (assign, nonatomic, getter = isEditingTokens, setter = setEditingTokens:) BOOL bEditingTokens;

- (IBAction)insertNewItem:(id)sender;

@end
