//
//  GlucoseLevelList.h
//  DBMonitor
//
//  Created by Wayne Hoy on 2014-06-08.
//  Copyright (c) 2014 Wayne Hoy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GlucoseLevelList : NSObject

@property NSDate* minTime;
@property float minGlucose;
@property NSDate* maxTime;
@property float maxGlucose;
@property NSArray *sortedGlucose;


+ (GlucoseLevelList *)sharedInstance;
- (GlucoseLevelList *)initWithUrl:(NSURL *)url;
- (NSArray *) refresh;

- (NSArray *) glucoseLevelsSince:(NSDate *)dateTime;
- (NSArray *) glucoseExtremesSince:(NSDate *)dateTime;
- (NSArray *) glucoseExtremes;

@end


