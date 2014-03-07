//
//  rpgScore.h
//  ezRPG
//
//  Created by Elie Zananiri on 2014-03-07.
//  Copyright (c) 2014 silentlyCrashing::net. All rights reserved.
//

#import <Foundation/Foundation.h>

@class rpgQuestion;
@class rpgToken;

@interface rpgScore : NSObject

- (id)initWithJSON:(id)JSON;

@property (strong, nonatomic) NSString *scoreID;
@property (strong, nonatomic) NSString *questionID;
@property (strong, nonatomic) NSString *tokenID;
@property (assign, nonatomic) NSInteger yesPoints;
@property (assign, nonatomic) NSInteger noPoints;
@property (strong, nonatomic) NSDate *createdAt;

@property (strong, nonatomic) rpgQuestion *question;
@property (strong, nonatomic) rpgToken *token;

@end
