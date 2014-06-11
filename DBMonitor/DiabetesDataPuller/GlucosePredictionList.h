//
//  GlucosePredictionList.h
//  DBMonitor
//
//  Created by Wayne Hoy on 2014-06-10.
//  Copyright (c) 2014 Wayne Hoy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GlucosePredictionList : NSObject

@property NSArray *sortedPredictions;

+ (void) setMaxPredictions: (int) max;
+ (GlucosePredictionList *)sharedInstance;
- (GlucosePredictionList *)initWithUrl:(NSURL *)url;
- (NSArray *) refresh;

@end

