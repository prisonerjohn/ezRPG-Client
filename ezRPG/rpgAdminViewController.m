//
//  rpgAdminViewController.m
//  ezRPG
//
//  Created by Elie Zananiri on 2014-03-05.
//  Copyright (c) 2014 silentlyCrashing::net. All rights reserved.
//

#import "rpgAdminViewController.h"

#import "rpgEditItemsViewController.h"

@interface rpgAdminViewController ()

@end

@implementation rpgAdminViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"EditItemsSegue"]) {
        rpgEditItemsViewController *vc = segue.destinationViewController;
        [vc setEditingTokens:self.isEditingTokens];
    }
}

#pragma mark - UI Callback Methods

- (IBAction)editTokens:(id)sender
{
    [self setEditingTokens:YES];
    [self performSegueWithIdentifier:@"EditItemsSegue"
                              sender:self];
}

- (IBAction)editQuestions:(id)sender
{
    [self setEditingTokens:NO];
    [self performSegueWithIdentifier:@"EditItemsSegue"
                              sender:self];
}

@end
