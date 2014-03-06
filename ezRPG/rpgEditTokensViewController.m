//
//  rpgEditTokensViewController.m
//  ezRPG
//
//  Created by Elie Zananiri on 2014-03-05.
//  Copyright (c) 2014 silentlyCrashing::net. All rights reserved.
//

#import "rpgEditTokensViewController.h"

#import "AFHTTPRequestOperationManager.h"
#import "rpgGlobals.h"
#import "rpgToken.h"

@interface rpgEditTokensViewController () <UIAlertViewDelegate>

@property (strong, nonatomic) NSMutableArray *tokens;
@property (assign, nonatomic) NSInteger editingTokenIndex;

- (void)updateTokens:(id)sender;
- (void)insertNewToken:(id)sender;

@end

@implementation rpgEditTokensViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tokens = [NSMutableArray array];
    
    // Add a + button to the nav bar.
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                               target:self
                                                                               action:@selector(insertNewToken:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    // Hook up a callback to the refresh control.
    [self.refreshControl addTarget:self
                            action:@selector(updateTokens:)
                  forControlEvents:UIControlEventValueChanged];
	
    [self updateTokens:self];
}

- (void)updateTokens:(id)sender
{
    // Load the list of tokens from the server.
    [[AFHTTPRequestOperationManager manager] GET:[NSString stringWithFormat:@"%@/tokens", kApiBaseURL]
                                      parameters:nil
                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                             if ([sender respondsToSelector:@selector(endRefreshing)]) {
                                                 [sender endRefreshing];
                                             }
                                             NSLog(@"JSON: %@", responseObject);
                                             NSArray *tokensArray = responseObject;
                                             [self.tokens removeAllObjects];
                                             for (NSDictionary *tokenDict in tokensArray) {
                                                 rpgToken *token = [[rpgToken alloc] initWithJSON:tokenDict];
                                                 [self.tokens addObject:token];
                                             }
                                             [self.tableView reloadData];
                                         }
                                         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             if ([sender respondsToSelector:@selector(endRefreshing)]) {
                                                 [sender endRefreshing];
                                             }
                                             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                                                                 message:error.localizedDescription
                                                                                                delegate:nil
                                                                                       cancelButtonTitle:@"OK"
                                                                                       otherButtonTitles:nil];
                                             [alertView show];
                                         }];
}

- (void)insertNewToken:(id)sender
{
    self.editingTokenIndex = -1;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Add Token"
                                                        message:@"Enter the new token name:"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"OK", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView setDelegate:self];
    [alertView show];
}

#pragma mark - UITableView Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tokens.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTokenCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kTokenCellIdentifier];
    }
    
    // Only fill in the cells if there is data available.
    if ([self.tokens count] > indexPath.row) {
        [cell.textLabel setText:[[self.tokens objectAtIndex:indexPath.row] name]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the token on the server.
        [[AFHTTPRequestOperationManager manager] DELETE:[NSString stringWithFormat:@"%@/token/%@", kApiBaseURL, [[self.tokens objectAtIndex:indexPath.row] tokenID]]
                                             parameters:nil
                                                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                    NSLog(@"JSON: %@", responseObject);
                                                    [self.tokens removeObjectAtIndex:indexPath.row];
                                                    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                                                     withRowAnimation:UITableViewRowAnimationFade];
                                                }
                                                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                                                                        message:error.localizedDescription
                                                                                                       delegate:nil
                                                                                              cancelButtonTitle:@"OK"
                                                                                              otherButtonTitles:nil];
                                                    [alertView show];
                                                }];
    }
}

#pragma mark - UITableView Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.editingTokenIndex = indexPath.row;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Edit Token"
                                                        message:@"Enter the new token name:"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"OK", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [[alertView textFieldAtIndex:0] setText:[[self.tokens objectAtIndex:indexPath.row] name]];
    [alertView setDelegate:self];
    [alertView show];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

#pragma mark - UIAlertView Delegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex) return;
    
    NSString *newName = [[alertView textFieldAtIndex:0] text];
    
    if (self.editingTokenIndex == -1) {
        // Add the token on the server.
        [[AFHTTPRequestOperationManager manager] POST:[NSString stringWithFormat:@"%@/token/new", kApiBaseURL]
                                          parameters:@{@"name" : newName}
                                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                 NSLog(@"JSON: %@", responseObject);
                                                 NSDictionary *tokenDict = responseObject;
                                                 rpgToken *token = [[rpgToken alloc] initWithJSON:tokenDict];
                                                 [self.tokens addObject:token];
                                                 [self.tableView reloadData];
                                             }
                                             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                                                                     message:error.localizedDescription
                                                                                                    delegate:nil
                                                                                           cancelButtonTitle:@"OK"
                                                                                           otherButtonTitles:nil];
                                                 [alertView show];
                                             }];
    }
    else {
        // Update the existing token on the server.
        [[AFHTTPRequestOperationManager manager] PUT:[NSString stringWithFormat:@"%@/token/%@", kApiBaseURL, [[self.tokens objectAtIndex:self.editingTokenIndex] tokenID]]
                                             parameters:@{@"name" : newName}
                                                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                    NSLog(@"JSON: %@", responseObject);
                                                    [[self.tokens objectAtIndex:self.editingTokenIndex] setName:newName];
                                                    [self.tableView reloadData];
                                                }
                                                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                                                                        message:error.localizedDescription
                                                                                                       delegate:nil
                                                                                              cancelButtonTitle:@"OK"
                                                                                              otherButtonTitles:nil];
                                                    [alertView show];
                                                }];
    }
}

@end
