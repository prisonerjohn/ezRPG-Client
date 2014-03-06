//
//  rpgToken.m
//  ezRPG
//
//  Created by Elie Zananiri on 2014-03-05.
//  Copyright (c) 2014 silentlyCrashing::net. All rights reserved.
//

#import "rpgToken.h"

static NSDateFormatter *sRFC3339DateFormatter;

@implementation rpgToken

- (id)initWithJSON:(id)JSON
{
    self = [super init];
    if (self) {
        if (sRFC3339DateFormatter == nil) {
            sRFC3339DateFormatter = [[NSDateFormatter alloc] init];
            NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            [sRFC3339DateFormatter setLocale:enUSPOSIXLocale];
            [sRFC3339DateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
            [sRFC3339DateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        }
        
        [self setTokenID:[JSON objectForKey:@"_id"]];
        [self setName:[JSON objectForKey:@"name"]];
        [self setCreatedAt:[sRFC3339DateFormatter dateFromString:[JSON objectForKey:@"created_at"]]];
    }
    return self;
}

@end
