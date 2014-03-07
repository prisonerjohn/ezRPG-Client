//
//  rpgScore.m
//  ezRPG
//
//  Created by Elie Zananiri on 2014-03-07.
//  Copyright (c) 2014 silentlyCrashing::net. All rights reserved.
//

#import "rpgScore.h"

#import "rpgGlobals.h"

@implementation rpgScore

- (id)initWithJSON:(id)JSON
{
    self = [super init];
    if (self) {
        [self setScoreID:[JSON objectForKey:@"_id"]];
        [self setQuestionID:[JSON objectForKey:@"qId"]];
        [self setTokenID:[JSON objectForKey:@"tId"]];
        [self setYesPoints:[[JSON objectForKey:@"yes"] integerValue]];
        [self setNoPoints:[[JSON objectForKey:@"no"] integerValue]];
//        [self setCreatedAt:[[rpgGlobals sRFC3339DateFormatter] dateFromString:[JSON objectForKey:@"created_at"]]];
    }
    return self;
}

@end
