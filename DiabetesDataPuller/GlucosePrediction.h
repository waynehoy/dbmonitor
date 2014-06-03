//
//  GlucosePrediction.h
//  DBMonitor
//
//  Created by Wayne Hoy on 2014-06-03.
//  Copyright (c) 2014 Wayne Hoy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GlucosePrediction : NSObject

@property NSDate *time;
@property double deviation;
@property double timeToGo;

+ (GlucosePrediction *) lastPrediction;

+ (void) setMaxPredictions: (int) max;
+ (NSArray *) refreshPredictionsArray;
+ (NSArray *) predictionsArray;

@end
