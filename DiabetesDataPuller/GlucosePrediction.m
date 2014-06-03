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
@synthesize reading = _reading;
@synthesize msg = _msg;


// Static singleton accessor methods and preferences
static NSArray *classPredictionsArray = nil;
static int classMaxPredictions = 20;

+ (void) setMaxPredictions: (int) max
{
    if (max > 0) {
        classMaxPredictions = max;
    }
}


// Poll the web server to get the latest set of alerts
+ (NSArray *) _refreshPredictionsHelper
{
    NSURL *alertsUrl = [NSURL URLWithString:
                            [NSString stringWithFormat:@"http://wotkit.sensetecnic.com/api/sensors/mike.glucose/data?beforeE=%d",classMaxPredictions]]; // TODO WKH new URL for predictions
    NSURLRequest *request = [NSURLRequest requestWithURL:alertsUrl];
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *predictJson = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSArray *ary = (NSArray *)[NSJSONSerialization JSONObjectWithData:predictJson options:0 error:&error];
    
    // Here we have an NSArray of NSDictionary objects representing the JSON response from the server
    // Turn the first one into a GlucosePrediction objects
    NSMutableArray *predictObjAry = [[NSMutableArray alloc] init];
    for (int i = 0; i < [ary count]; i++) {
        NSDictionary *dict = [ary objectAtIndex:i];
        
        NSDate *time = [NSDate dateWithTimeIntervalSince1970:([[dict objectForKey:@"timestamp"] doubleValue]/1000)];
        double reading = [((NSString *)[dict objectForKey:@"value"]) doubleValue];
        NSString *msg = [dict objectForKey:@"value"];  // TODO WKH Change the key
        
        GlucosePrediction *predict = [[GlucosePrediction alloc] init];
        predict.time = time;
        predict.reading = reading;
        predict.msg = msg;
        
        [predictObjAry addObject:predict];
    }
    
    
    // Sort the array in time, store it in the class variable, and return
    NSSortDescriptor* sortOrder = [NSSortDescriptor sortDescriptorWithKey: @"self" ascending: NO];
    //    NSArray *sorted = [ary sortedArrayUsingSelector:@selector(compare:)];
    NSArray *sorted = [predictObjAry sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortOrder]];
    
    NSAssert(sorted.count == predictObjAry.count, @"valid");
    classPredictionsArray = sorted;
    //NSAssert(sorted.count == 144, @"valid");
    return classPredictionsArray;
}


// Force a refresh of the alerts array
+ (NSArray *) refreshPredictionsArray
{
    return [GlucosePrediction _refreshPredictionsHelper];
}

// Get the existing alerts array
+ (NSArray *) predictionsArray
{
    if (classPredictionsArray == nil) {
        // Refresh it
        return [GlucosePrediction refreshPredictionsArray];
    }
    return classPredictionsArray;
}


// Get the existing alerts array
+ (GlucosePrediction *) lastPrediction
{
    NSArray *ary = [GlucosePrediction predictionsArray];
    return [ary firstObject];
}

// Override the compare method to allow sorting by time
- (NSComparisonResult)compare:(GlucosePrediction *)anotherPred
{
    return [self.time compare:anotherPred.time];
}


@end
