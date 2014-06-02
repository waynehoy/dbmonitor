//
//  glucoseLevel.m
//  DiabetesDataPuller
//
//  Created by Tim Orbasido on 2014-06-02.
//  Copyright (c) 2014 Group4. All rights reserved.
//

#import "glucoseLevel.h"
#import <Foundation/NSDate.h>

@implementation GlucoseLevel

@synthesize time = _time;
@synthesize glucose = _glucose;

- (NSComparisonResult)compare:(GlucoseLevel *)anotherLevel{
    
    return [self.time compare:anotherLevel.time];
}

- (NSString*)description{
    
    
    return [NSString stringWithFormat:@"Gluclose Level %@ %f", [self.time description], self.glucose];
}

@end
