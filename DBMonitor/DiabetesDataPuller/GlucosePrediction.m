//
//  GlucosePrediction.m
//  DBMonitor
//
//  Created by Wayne Hoy on 2014-06-03.
//  Copyright (c) 2014 Wayne Hoy. All rights reserved.
//

#import "GlucosePrediction.h"

@implementation GlucosePrediction


@synthesize time = _time;
@synthesize deviation = _deviation;
@synthesize timeToGo = _timeToGo;

// Override the compare method to allow sorting by time
- (NSComparisonResult)compare:(GlucosePrediction *)anotherPred
{
    return [self.time compare:anotherPred.time];
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"Prediction time %@, deviation %.0f, time to go %.2f",
            [self.time description], self.deviation, self.timeToGo];
}


@end
