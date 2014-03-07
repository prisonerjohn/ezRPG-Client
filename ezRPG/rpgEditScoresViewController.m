//
//  rpgEditScoresViewController.m
//  ezRPG
//
//  Created by Elie Zananiri on 2014-03-06.
//  Copyright (c) 2014 silentlyCrashing::net. All rights reserved.
//

#import "rpgEditScoresViewController.h"

#import "AFHTTPRequestOperationManager.h"
#import "rpgGlobals.h"
#import "rpgQuestion.h"
#import "rpgScore.h"
#import "rpgScoreCell.h"
#import "rpgToken.h"

@interface rpgEditScoresViewController () <UIAlertViewDelegate>

@property (strong, nonatomic) NSMutableArray *scores;

- (void)updateScores:(id)sender;
- (void)fetchItems:(id)sender;
- (void)saveScores:(id)sender;

- (void)pointsValueChanged:(UIView *)sender;

@end

@implementation rpgEditScoresViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.scores = [NSMutableArray array];

    // Hook up a callback to the refresh control.
    [self.refreshControl addTarget:self
                            action:@selector(updateScores:)
                  forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.isEditingTokens) {
        [self.navigationItem setTitle:self.token.name];
    }
    else {
        [self.navigationItem setTitle:self.question.name];
    }
    
    [self updateScores:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self saveScores:self];
    
    [super viewWillDisappear:animated];
}

- (void)updateScores:(id)sender
{
    // Get the current scores.
    NSString *urlString;
    if (self.isEditingTokens) {
        urlString = [NSString stringWithFormat:@"%@/scores/t/%@", kApiBaseURL, self.token.tokenID];
    }
    else {
        urlString = [NSString stringWithFormat:@"%@/scores/q/%@", kApiBaseURL, self.question.questionID];
    }
    
    [[AFHTTPRequestOperationManager manager] GET:urlString
                                      parameters:nil
                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                             NSLog(@"JSON: %@", responseObject);
                                             NSArray *scoresArray = responseObject;
                                             [self.scores removeAllObjects];
                                             for (NSDictionary *scoreDict in scoresArray) {
                                                 rpgScore *score = [[rpgScore alloc] initWithJSON:scoreDict];
                                                 if (self.isEditingTokens) {
                                                     [score setToken:self.token];
                                                 }
                                                 else {
                                                     [score setQuestion:self.question];
                                                 }
                                                 [self.scores addObject:score];
                                             }
                                             
                                             [self fetchItems:sender];
                                         }
                                         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             [rpgGlobals handleError:error];
                                         }];
}

- (void)fetchItems:(id)sender
{
    // Load all items.
    [[AFHTTPRequestOperationManager manager] GET:[NSString stringWithFormat:@"%@/%@", kApiBaseURL, self.isEditingTokens? @"questions":@"tokens"]
                                      parameters:nil
                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                             NSLog(@"JSON: %@", responseObject);
                                             NSArray *itemsArray = responseObject;
                                             for (NSDictionary *itemDict in itemsArray) {
                                                 if (self.isEditingTokens) {
                                                     rpgQuestion *question = [[rpgQuestion alloc] initWithJSON:itemDict];
                                                     // Look for a matching score in the list.
                                                     rpgScore *matchScore;
                                                     for (rpgScore *score in self.scores) {
                                                         if ([score.questionID isEqualToString:question.questionID]) {
                                                             matchScore = score;
                                                             break;
                                                         }
                                                     }
                                                     if (matchScore == nil) {
                                                         // No match found, create a new score.
                                                         matchScore = [[rpgScore alloc] init];
                                                         [matchScore setToken:self.token];
                                                         [self.scores addObject:matchScore];
                                                     }
                                                     [matchScore setQuestion:question];
                                                 }
                                                 else {
                                                     rpgToken *token = [[rpgToken alloc] initWithJSON:itemDict];
                                                     // Look for a matching score in the list.
                                                     rpgScore *matchScore;
                                                     for (rpgScore *score in self.scores) {
                                                         if ([score.tokenID isEqualToString:token.tokenID]) {
                                                             matchScore = score;
                                                             break;
                                                         }
                                                     }
                                                     if (matchScore == nil) {
                                                         // No match found, create a new score.
                                                         matchScore = [[rpgScore alloc] init];
                                                         [matchScore setQuestion:self.question];
                                                         [self.scores addObject:matchScore];
                                                     }
                                                     [matchScore setToken:token];
                                                 }
                                             }
                                             
                                             if ([sender respondsToSelector:@selector(endRefreshing)]) {
                                                 [sender endRefreshing];
                                             }
                                             [self.tableView reloadData];
                                         }
                                         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             if ([sender respondsToSelector:@selector(endRefreshing)]) {
                                                 [sender endRefreshing];
                                             }
                                             [rpgGlobals handleError:error];
                                         }];
}

- (void)saveScores:(id)sender
{
    NSMutableArray *scoresArray = [NSMutableArray array];
    for (rpgScore *score in self.scores) {
        NSMutableDictionary *scoreDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          score.token.tokenID, @"tId",
                                          score.question.questionID, @"qId",
                                          @(score.yesPoints), @"yes",
                                          @(score.noPoints), @"no" ,
                                          nil];
                                               
        if (score.scoreID) {
            [scoreDict setObject:score.scoreID forKey:@"_id"];
        }
        
        [scoresArray addObject:scoreDict];
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager PUT:[NSString stringWithFormat:@"%@/scores", kApiBaseURL]
      parameters:@{@"scores": scoresArray}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"JSON: %@", responseObject);
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [rpgGlobals handleError:error];
         }];
}

#pragma mark - UI Callback Methods

- (IBAction)editItem:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Edit %@", self.isEditingTokens? @"Token":@"Question"]
                                                        message:[NSString stringWithFormat:@"Enter the new %@ name:", self.isEditingTokens? @"token":@"question"]
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"OK", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [[alertView textFieldAtIndex:0] setText:(self.isEditingTokens? self.token.name:self.question.name)];
    [alertView setDelegate:self];
    [alertView show];
}

- (void)pointsValueChanged:(UIView *)sender
{
    // Find the parent cell.
    UIView *cellView = sender;
    do {
        cellView = cellView.superview;
    } while (cellView.superview && ![cellView isKindOfClass:[UITableViewCell class]]);
    rpgScoreCell *cell = (rpgScoreCell *)cellView;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSLog(@"Index %d changed", indexPath.row);
    
    // Update the score.
    rpgScore *score = [self.scores objectAtIndex:indexPath.row];
    [score setYesPoints:[[cell.yesTextField text] integerValue]];
    [score setNoPoints:[[cell.noTextField text] integerValue]];
}

#pragma mark - UIAlertView Delegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex) return;
    
    NSString *urlString;
    if (self.isEditingTokens) {
        urlString = [NSString stringWithFormat:@"%@/token/%@", kApiBaseURL, self.token.tokenID];
    }
    else {
        urlString = [NSString stringWithFormat:@"%@/question/%@", kApiBaseURL, self.question.questionID];
    }
    
    NSString *newName = [[alertView textFieldAtIndex:0] text];
    
    // Update the existing item on the server.
    [[AFHTTPRequestOperationManager manager] PUT:urlString
                                      parameters:@{@"name" : newName}
                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                             NSLog(@"JSON: %@", responseObject);
                                             if (self.isEditingTokens) {
                                                 [self.token setName:newName];
                                             }
                                             else {
                                                 [self.question setName:newName];
                                             }
                                             [self.navigationItem setTitle:newName];
                                             [self.tableView reloadData];
                                         }
                                         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             [rpgGlobals handleError:error];
                                         }];
    
}

#pragma mark - UITableView Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.scores.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    rpgScoreCell *cell = [tableView dequeueReusableCellWithIdentifier:kScoreCellIdentifier];
    [cell.yesTextField removeTarget:nil
                             action:NULL
                   forControlEvents:UIControlEventAllEvents];
    [cell.yesTextField addTarget:self
                          action:@selector(pointsValueChanged:)
                forControlEvents:UIControlEventEditingDidEnd];
    [cell.noTextField removeTarget:nil
                            action:NULL
                  forControlEvents:UIControlEventAllEvents];
    [cell.noTextField addTarget:self
                         action:@selector(pointsValueChanged:)
               forControlEvents:UIControlEventEditingDidEnd];

    // Only fill in the cells if there is data available.
    if ([self.scores count] > indexPath.row) {
        rpgScore *score = [self.scores objectAtIndex:indexPath.row];
        if (self.bEditingTokens) {
            [cell.textLabel setText:score.question.name];
        }
        else {
            [cell.textLabel setText:score.token.name];
        }
        
        UITextField *yesTextField = (UITextField *)[cell viewWithTag:1];
        [yesTextField setText:[NSString stringWithFormat:@"%d", score.yesPoints]];
        UITextField *noTextField = (UITextField *)[cell viewWithTag:2];
        [noTextField setText:[NSString stringWithFormat:@"%d", score.noPoints]];
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
