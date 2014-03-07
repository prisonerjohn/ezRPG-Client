//
//  rpgQuestion.h
//  ezRPG
//
//  Created by Elie Zananiri on 2014-03-06.
//  Copyright (c) 2014 silentlyCrashing::net. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface rpgQuestion : NSObject

- (id)initWithJSON:(id)JSON;

@property (strong, nonatomic) NSString *questionID;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSDate *createdAt;

@end
