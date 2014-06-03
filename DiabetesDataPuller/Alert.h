//
//  Alert.h
//  DiabetesDataPuller
//
//  Created by Tim Orbasido on 2014-06-02.
//  Copyright (c) 2014 Group4. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Alert : NSObject

@property NSDate *time;
@property NSString *priority;
@property NSString *title;
@property NSString *msg;

+ (void) setMaxAlerts: (int) max;
+ (NSArray *) refreshAlertsArray;
+ (NSArray *) alertsArray;


@end
