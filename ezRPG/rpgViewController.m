//
//  rpgViewController.m
//  ezRPG
//
//  Created by Elie Zananiri on 2014-03-05.
//  Copyright (c) 2014 silentlyCrashing::net. All rights reserved.
//

#import "rpgViewController.h"

@interface rpgViewController ()

- (void)presentAdminView:(UISwipeGestureRecognizer *)recognizer;

@end

#pragma mark

@implementation rpgViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Add a gesture recognizer for opening the admin view.
    UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                                 action:@selector(presentAdminView:)];
    [swipeGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionUp];
#if TARGET_IPHONE_SIMULATOR
    [swipeGestureRecognizer setNumberOfTouchesRequired:1];
#else
    [swipeGestureRecognizer setNumberOfTouchesRequired:3];
#endif
    [self.view addGestureRecognizer:swipeGestureRecognizer];

}

- (void)presentAdminView:(UISwipeGestureRecognizer *)recognizer
{
    [self performSegueWithIdentifier:@"AdminSegue"
                              sender:self];
}

@end
