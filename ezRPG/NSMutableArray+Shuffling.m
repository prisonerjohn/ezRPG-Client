//
//  NSMutableArray+Shuffling.m
//  ezRPG
//
//  Created by Elie Zananiri on 2014-03-07.
//  Copyright (c) 2014 silentlyCrashing::net. All rights reserved.
//

#import "NSMutableArray+Shuffling.h"

@implementation NSMutableArray (Shuffling)

// http://stackoverflow.com/a/56656/318077
- (void)shuffle
{
    NSUInteger count = [self count];
    for (NSUInteger i = 0; i < count; ++i) {
        // Select a random element between i and end of array to swap with.
        NSInteger nElements = count - i;
        NSInteger n = arc4random_uniform(nElements) + i;
        [self exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
}

@end
