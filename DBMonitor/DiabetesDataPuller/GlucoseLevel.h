//
//  glucoseLevel.h
//  DiabetesDataPuller
//
//  Created by Tim Orbasido on 2014-06-02.
//  Copyright (c) 2014 Group4. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/NSDate.h>

@interface GlucoseLevel : NSObject

@property NSDate* time;
@property float glucose;

@property NSDate* minTime;
@property float minGlucose;

@property NSDate* maxtime;
@property float maxGlucose;

- (NSComparisonResult)compare:(GlucoseLevel *)anotherLevel;

@end
