//
//  rpgToken.h
//  ezRPG
//
//  Created by Elie Zananiri on 2014-03-05.
//  Copyright (c) 2014 silentlyCrashing::net. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface rpgToken : NSObject

- (id)initWithJSON:(id)JSON;

@property (strong, nonatomic) NSString *tokenID;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSDate *createdAt;

@end
