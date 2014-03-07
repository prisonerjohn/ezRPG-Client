//
//  rpgEditItemsViewController.m
//  ezRPG
//
//  Created by Elie Zananiri on 2014-03-06.
//  Copyright (c) 2014 silentlyCrashing::net. All rights reserved.
//

#import "rpgEditItemsViewController.h"

#import "AFHTTPRequestOperationManager.h"
#import "rpgEditStatsViewController.h"
#import "rpgGlobals.h"
#import "rpgQuestion.h"
#import "rpgToken.h"

@interface rpgEditItemsViewController () <UIAlertViewDelegate>

@property (strong, nonatomic) NSMutableArray *items;
@property (assign, nonatomic) rpgQuestion *selectedQuestion;
@property (assign, nonatomic) rpgToken *selectedToken;

- (void)updateItems:(id)sender;
- (void)handleError:(NSError *)error;

@end

@implementation rpgEditItemsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.items = [NSMutableArray array];
    
    // Hook up a callback to the refresh control.
    [self.refreshControl addTarget:self
                            action:@selector(updateItems:)
                  forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateItems:self];
}

- (void)updateItems:(id)sender
{
    // Load the list of items from the server.
    [[AFHTTPRequestOperationManager manager] GET:[NSString stringWithFormat:@"%@/%@", kApiBaseURL, self.isEditingTokens? @"tokens":@"questions"]
                                      parameters:nil
                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                             if ([sender respondsToSelector:@selector(endRefreshing)]) {
                                                 [sender endRefreshing];
                                             }
                                             NSLog(@"JSON: %@", responseObject);
                                             NSArray *itemsArray = responseObject;
                                             [self.items removeAllObjects];
                                             for (NSDictionary *itemDict in itemsArray) {
                                                 if (self.isEditingTokens) {
                                                     rpgToken *token = [[rpgToken alloc] initWithJSON:itemDict];
                                                     [self.items addObject:token];
                                                 }
                                                 else {
                                                     rpgQuestion *question = [[rpgQuestion alloc] initWithJSON:itemDict];
                                                     [self.items addObject:question];
                                                 }
                                             }
                                             [self.tableView reloadData];
                                         }
                                         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             if ([sender respondsToSelector:@selector(endRefreshing)]) {
                                                 [sender endRefreshing];
                                             }
                                             [self handleError:error];
                                         }];
}

- (IBAction)insertNewItem:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Add %@", self.isEditingTokens? @"Token":@"Question"]
                                                        message:[NSString stringWithFormat:@"Enter the new %@ name:", self.isEditingTokens? @"token":@"question"]
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"OK", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView setDelegate:self];
    [alertView show];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"EditStatsSegue"]) {
        rpgEditStatsViewController *vc = segue.destinationViewController;
        [vc setEditingTokens:self.isEditingTokens];
        if (self.isEditingTokens) {
            vc.token = self.selectedToken;
        }
        else {
            vc.question = self.selectedQuestion;
        }
    }
}

- (void)handleError:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

#pragma mark - UIAlertView Delegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex) return;
    
    NSString *newName = [[alertView textFieldAtIndex:0] text];
    
    // Add the item on the server.
    [[AFHTTPRequestOperationManager manager] POST:[NSString stringWithFormat:@"%@/%@/new", kApiBaseURL, self.isEditingTokens? @"token":@"question"]
                                       parameters:@{ @"name" : newName }
                                          success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                              NSLog(@"JSON: %@", responseObject);
                                              NSDictionary *itemDict = responseObject;
                                              if (self.bEditingTokens) {
                                                  rpgToken *token = [[rpgToken alloc] initWithJSON:itemDict];
                                                  [self.items addObject:token];
                                              }
                                              else {
                                                  rpgQuestion *question = [[rpgQuestion alloc] initWithJSON:itemDict];
                                                  [self.items addObject:question];
                                              }
                                              [self.tableView reloadData];
                                          }
                                          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                              [self handleError:error];
                                          }];
}

#pragma mark - UITableView Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = (self.isEditingTokens? kTokenCellIdentifier:kQuestionCellIdentifier);
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    // Only fill in the cells if there is data available.
    if ([self.items count] > indexPath.row) {
        if (self.bEditingTokens) {
            rpgToken *token = [self.items objectAtIndex:indexPath.row];
            [cell.textLabel setText:token.name];
        }
        else {
            rpgQuestion *question = [self.items objectAtIndex:indexPath.row];
            [cell.textLabel setText:question.name];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the item on the server.
        NSString *urlString;
        if (self.isEditingTokens) {
            rpgToken *token = [self.items objectAtIndex:indexPath.row];
            urlString = [NSString stringWithFormat:@"%@/token/%@", kApiBaseURL, token.tokenID];
        }
        else {
            rpgQuestion *question = [self.items objectAtIndex:indexPath.row];
            urlString = [NSString stringWithFormat:@"%@/question/%@", kApiBaseURL, question.questionID];
        }
        
        [[AFHTTPRequestOperationManager manager] DELETE:urlString
                                             parameters:nil
                                                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                    NSLog(@"JSON: %@", responseObject);
                                                    [self.items removeObjectAtIndex:indexPath.row];
                                                    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                                                     withRowAnimation:UITableViewRowAnimationFade];
                                                }
                                                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                    [self handleError:error];
                                                }];
    }
}

#pragma mark - UITableView Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isEditingTokens) {
        self.selectedToken = [self.items objectAtIndex:indexPath.row];
        self.selectedQuestion = nil;
    }
    else {
        self.selectedToken = nil;
        self.selectedQuestion = [self.items objectAtIndex:indexPath.row];
    }
    
    [self performSegueWithIdentifier:@"EditStatsSegue"
                              sender:self];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

@end
