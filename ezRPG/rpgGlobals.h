//
//  rpgGlobals.h
//  ezRPG
//
//  Created by Elie Zananiri on 2014-03-05.
//  Copyright (c) 2014 silentlyCrashing::net. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG
#define kApiBaseURL @"http://localhost:5000"
#else
#define kApiBaseURL @"http://localhost:5000"
#endif

@interface rpgGlobals : NSObject

+ (NSDateFormatter *)sRFC3339DateFormatter;

@end
