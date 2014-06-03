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

@synthesize minTime;
@synthesize minGlucose;

@synthesize maxTime;
@synthesize maxGlucose;

@synthesize startTime;
@synthesize endTime;

-(NSArray *) getGlucose: (int) numTime{

    
    NSURL* glucoseURL = [NSURL URLWithString:@"http://wotkit.sensetecnic.com/api/sensors/mike.glucose/data?beforeE=288"]; // WKH TODO need to grab 288 for 24 hrs
    NSURLRequest* request = [NSURLRequest requestWithURL:glucoseURL];
    NSURLResponse* response = nil;
    NSError* error = nil;
    NSData* glucoseJson = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSObject *obj = [NSJSONSerialization JSONObjectWithData:glucoseJson options:0 error:&error];
    
    NSArray *ary = (NSArray *)obj;
    
    NSMutableArray* result = [[NSMutableArray alloc] init];
    
    bool firstTime = true;
    
    for (NSDictionary* dic in ary) {
        float value = [dic[@"value"] floatValue];
        
        //NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        //NSString *input = dic[@"timestamp_iso"];//@"2013-05-08T19:03:53+00:00";
        //                         "timestamp_iso" = "2014-06-02T10:28:00.000Z";
        //[dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"]; //iso 8601 format
        //NSDate *date = [dateFormat dateFromString:input];
        NSDate* date = [NSDate dateWithTimeIntervalSince1970: [dic[@"timestamp"] doubleValue]/1000];
        NSAssert(date, @"valid");
        
        GlucoseLevel* level = [[GlucoseLevel alloc] init];
        level.time = date;
        level.glucose = value;
        
        if(firstTime){
            self.minTime = level.time;
            self.startTime = level.time;
            self.minGlucose = level.glucose;
            
            self.maxTime = level.time;
            self.endTime = level.time;
            self.maxGlucose = level.glucose;
            
            firstTime = NO;
        }else{
            
            if ([level.time compare:self.endTime] == NSOrderedDescending)
                self.endTime = level.time;
            
            if ([level.time compare:self.startTime] == NSOrderedAscending)
                self.startTime = level.time;
            
            if(level.glucose<self.minGlucose){
                self.minTime = level.time;
                self.minGlucose = level.glucose;
            }
            
            
            if(level.glucose>self.maxGlucose){
                self.maxTime = level.time;
                self.maxGlucose = level.glucose;
            }
            
        }
        
        [result addObject:level];
    }
    
    NSArray* sorted = [result sortedArrayUsingSelector:@selector(compare:)];
    NSAssert(sorted.count == result.count, @"valid");
    //NSAssert(sorted.count == 144, @"valid");
    
    return sorted;
}

-(NSArray*)getGlucoseExtremes
{
    GlucoseLevel* levelmin = [[GlucoseLevel alloc] init];
    levelmin.time = self.minTime;
    levelmin.glucose = self.minGlucose;

    GlucoseLevel* levelmax = [[GlucoseLevel alloc] init];
    levelmax.time = self.maxTime;
    levelmax.glucose = self.maxGlucose;

    return [NSArray arrayWithObjects:levelmin, levelmax, nil];
}

-(NSArray *) getAlerts: (int) numAlerts{
    return nil;
}

-(int) getPrediction{
    return 0;
}

@end
