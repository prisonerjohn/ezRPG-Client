//
//  rpgToken.m
//  ezRPG
//
//  Created by Elie Zananiri on 2014-03-05.
//  Copyright (c) 2014 silentlyCrashing::net. All rights reserved.
//

#import "rpgToken.h"

#import "rpgGlobals.h"

@implementation rpgToken

- (id)initWithJSON:(id)JSON
{
    self = [super init];
    if (self) {
        [self setTokenID:[JSON objectForKey:@"_id"]];
        [self setName:[JSON objectForKey:@"name"]];
//        [self setCreatedAt:[[rpgGlobals sRFC3339DateFormatter] dateFromString:[JSON objectForKey:@"created_at"]]];
    }
    return self;
}

@end
