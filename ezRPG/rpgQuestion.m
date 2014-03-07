//
//  rpgQuestion.m
//  ezRPG
//
//  Created by Elie Zananiri on 2014-03-06.
//  Copyright (c) 2014 silentlyCrashing::net. All rights reserved.
//

#import "rpgQuestion.h"

#import "rpgGlobals.h"

@implementation rpgQuestion

- (id)initWithJSON:(id)JSON
{
    self = [super init];
    if (self) {
        [self setQuestionID:[JSON objectForKey:@"_id"]];
        [self setName:[JSON objectForKey:@"name"]];
        [self setCreatedAt:[[rpgGlobals sRFC3339DateFormatter] dateFromString:[JSON objectForKey:@"created_at"]]];
    }
    return self;
}

@end
