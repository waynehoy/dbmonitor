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
@property double reading;
@property NSString *msg;

+ (GlucosePrediction *) refreshPrediction;
+ (GlucosePrediction *) prediction;

@end
