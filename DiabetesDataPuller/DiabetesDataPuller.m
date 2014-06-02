//
//  DiabetesDataPuller.m
//  DiabetesDataPuller
//
//  Created by Tim Orbasido on 2014-06-02.
//  Copyright (c) 2014 Group4. All rights reserved.
//

#import "DiabetesDataPuller.h"
#import "GlucoseLevel.h"
#import <Foundation/NSDate.h>

@implementation DiabetesDataPuller

-(NSArray *) getGlucose: (int) numTime{
    
    NSURL* glucoseURL = [NSURL URLWithString:@"http://wotkit.sensetecnic.com/api/sensors/mike.blood-sensor/data"];
    NSURLRequest* request = [NSURLRequest requestWithURL:glucoseURL];
    NSURLResponse* response = nil;
    NSError* error = nil;
    NSData* glucoseJson = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSObject *obj = [NSJSONSerialization JSONObjectWithData:glucoseJson options:0 error:&error];
    
    
    NSArray *ary = (NSArray *)obj;
    
    NSMutableArray* result = [[NSMutableArray alloc] init];
    
    for (NSDictionary* dic in ary) {
        float value = [dic[@"value"] floatValue];
        NSDate* date = [NSDate dateWithTimeIntervalSince1970: [dic[@"timestamp"] doubleValue]/1000];
        
        GlucoseLevel* level = [[GlucoseLevel alloc] init];
        level.time = date;
        level.glucose = value;
        [result addObject:level];
    }
    
    NSArray* sorted = [result sortedArrayUsingSelector:@selector(compare:)];
    
    return sorted;
}

-(NSArray *) getAlerts: (int) numAlerts{
    return nil;
}

-(int) getPrediction{
    return 0;
}

@end
