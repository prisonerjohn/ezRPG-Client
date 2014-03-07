//
//  rpgGameViewController.m
//  ezRPG
//
//  Created by Elie Zananiri on 2014-03-07.
//  Copyright (c) 2014 silentlyCrashing::net. All rights reserved.
//

#import "rpgGameViewController.h"

#import "AFHTTPRequestOperationManager.h"
#import "JYRadarChart.h"
#import "NSMutableArray+Shuffling.h"
#import "rpgGlobals.h"
#import "rpgQuestion.h"
#import "rpgScore.h"
#import "rpgToken.h"

@interface rpgGameViewController ()

@property (weak, nonatomic) JYRadarChart *radarChart;

@property (strong, nonatomic) NSMutableArray *questions;
@property (strong, nonatomic) NSMutableArray *tokens;
@property (strong, nonatomic) NSMutableArray *scores;

@property (strong, nonatomic) NSMutableDictionary *points;
@property (assign, nonatomic) NSInteger questionIndex;
@property (assign, nonatomic) NSInteger maxPossiblePoints;

- (void)updateQuestions;
- (void)updateTokens;
- (void)updateScores;

- (void)startGame;
- (void)endGame;

- (void)startRound;
- (void)endRound:(BOOL)bAnswer;
- (void)pointsRound:(BOOL)bAnswer;

@end

@implementation rpgGameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.questions = [NSMutableArray array];
    self.tokens = [NSMutableArray array];
    self.scores = [NSMutableArray array];
    
    self.points = [NSMutableDictionary dictionary];

    JYRadarChart *radarChart = [[JYRadarChart alloc] initWithFrame:CGRectMake(128, 116, 512, 512)];
    [radarChart setSteps:4];
    [radarChart setR:(radarChart.frame.size.width * 0.4f)];
    [radarChart setColors:@[[UIColor colorWithRed:0.0f green:1.0f blue:0.0f alpha:0.5f]]];
    
    [self.view addSubview:radarChart];
    self.radarChart = radarChart;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.questionLabel setText:@""];
    [self.questionLabel setAlpha:0.0f];
    [self.yesButton setAlpha:0.0f];
    [self.noButton setAlpha:0.0f];
    [self.doneButton setAlpha:0.0f];
    
    [self updateQuestions];
}

- (void)updateQuestions
{
    // Load the list of questions from the server.
    [[AFHTTPRequestOperationManager manager] GET:[NSString stringWithFormat:@"%@/questions", kApiBaseURL]
                                      parameters:nil
                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                             NSLog(@"JSON: %@", responseObject);
                                             NSArray *questionsArray = responseObject;
                                             [self.questions removeAllObjects];
                                             for (NSDictionary *questionDict in questionsArray) {
                                                 rpgQuestion *question = [[rpgQuestion alloc] initWithJSON:questionDict];
                                                 [self.questions addObject:question];
                                             }
                                             
                                             [self updateTokens];
                                         }
                                         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             [rpgGlobals handleError:error];
                                         }];
}

- (void)updateTokens
{
    // Load the list of tokens from the server.
    [[AFHTTPRequestOperationManager manager] GET:[NSString stringWithFormat:@"%@/tokens", kApiBaseURL]
                                      parameters:nil
                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                             NSLog(@"JSON: %@", responseObject);
                                             NSArray *tokensArray = responseObject;
                                             [self.tokens removeAllObjects];
                                             for (NSDictionary *tokenDict in tokensArray) {
                                                 rpgToken *token = [[rpgToken alloc] initWithJSON:tokenDict];
                                                 [self.tokens addObject:token];
                                             }
                                             
                                             [self updateScores];
                                         }
                                         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             [rpgGlobals handleError:error];
                                         }];
}

- (void)updateScores
{
    // Load the list of scores from the server.
    [[AFHTTPRequestOperationManager manager] GET:[NSString stringWithFormat:@"%@/scores", kApiBaseURL]
                                      parameters:nil
                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                             NSLog(@"JSON: %@", responseObject);
                                             NSArray *scoresArray = responseObject;
                                             [self.scores removeAllObjects];
                                             for (NSDictionary *scoreDict in scoresArray) {
                                                 rpgScore *score = [[rpgScore alloc] initWithJSON:scoreDict];
                                                 [self.scores addObject:score];
                                             }
                                             
                                             [self startGame];
                                         }
                                         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             [rpgGlobals handleError:error];
                                         }];
}

- (void)startGame
{
    NSLog(@"Starting game!");
    
    // Reset points.
    [self.points removeAllObjects];
    for (rpgToken *token in self.tokens) {
        [self.points setObject:@0
                        forKey:token.name];
    }
    self.maxPossiblePoints = 0;

    // Reset chart.
    [self.radarChart setFillArea:NO];
    [self.radarChart setDataSeries:@[[self.points allValues]]];
    [self.radarChart setAttributes:[self.points allKeys]];
    
    [self.radarChart setNeedsDisplay];
    
    // Shuffle questions.
    [self.questions shuffle];
    
    // Start with the first question.
    self.questionIndex = 0;

    [self.questionLabel setAlpha:0.0f];
    [self.yesButton setAlpha:0.0f];
    [self.noButton setAlpha:0.0f];
    [self.doneButton setAlpha:0.0f];

    [self startRound];
}

- (void)endGame
{
    [self.radarChart setFillArea:YES];
    [self.radarChart setNeedsDisplay];

    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [self.doneButton setAlpha:1.0f];
                     }
                     completion:nil];
}

- (void)startRound
{
    [self.questionLabel setText:[[self.questions objectAtIndex:self.questionIndex] name]];
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [self.questionLabel setAlpha:1.0f];
                     }
                     completion:nil];
    [UIView animateWithDuration:0.5
                          delay:0.25
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [self.yesButton setAlpha:1.0f];
                         [self.noButton setAlpha:1.0f];
                     }
                     completion:nil];
}

- (void)endRound:(BOOL)bAnswer
{
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [self.questionLabel setAlpha:0.0f];
                         [self.yesButton setAlpha:0.0f];
                         [self.noButton setAlpha:0.0f];
                     }
                     completion:^(BOOL finished) {
                         [self pointsRound:bAnswer];
                     }];
}

- (void)pointsRound:(BOOL)bAnswer
{
    NSInteger roundMax = 0;
    
    // Update all the points.
    rpgQuestion *question = [self.questions objectAtIndex:self.questionIndex];
    for (rpgScore *score in self.scores) {
        if ([score.questionID isEqualToString:question.questionID]) {
            rpgToken *token;
            for (rpgToken *t in self.tokens) {
                if ([score.tokenID isEqualToString:t.tokenID]) {
                    token = t;
                    break;
                }
            }
            if (token) {
                NSInteger pt = [[self.points objectForKey:token.name] integerValue];
                pt += (bAnswer? score.yesPoints:score.noPoints);
                [self.points setObject:@(pt)
                                forKey:token.name];
                roundMax = MAX(roundMax, MAX(score.yesPoints, score.noPoints));
            }
        }
    }
    
    self.maxPossiblePoints += roundMax;
    
    NSLog(@"New points: %@", self.points);
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [self.radarChart setDataSeries:@[[self.points allValues]]];
                         [self.radarChart setMaxValue:self.maxPossiblePoints];
                         
                         [self.radarChart setNeedsDisplay];
                     }
                     completion:^(BOOL finished) {
                         ++self.questionIndex;
                         if (self.questionIndex < [self.questions count]) {
                             // One more round.
                             [self startRound];
                         }
                         else {
                             // All done, end the game!
                             [self endGame];
                         }
                     }];
}

#pragma mark - UI Callback Methods

- (IBAction)yesSelected:(id)sender
{
    [self endRound:YES];
}

- (IBAction)noSelected:(id)sender
{
    [self endRound:NO];
}

- (IBAction)doneSelected:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
