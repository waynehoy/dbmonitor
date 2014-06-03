//
//  DiabetesDataPuller.h
//  DiabetesDataPuller
//
//  Created by Tim Orbasido on 2014-06-02.
//  Copyright (c) 2014 Group4. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DiabetesDataPuller : NSObject

@property NSDate* minTime;
@property float minGlucose;

@property NSDate* maxTime;
@property float maxGlucose;

@property NSDate* startTime;
@property NSDate* endTime;

@property NSArray *sortedGlucose;

-(NSArray *) getGlucose: (int) numTime;
-(NSArray*)getGlucoseExtremes;
-(NSArray *)getGlucoseExtremesWithinRange:(NSRange) range;

-(NSArray *) getAlerts: (int) numAlerts;
-(int) getPrediction;

@end
