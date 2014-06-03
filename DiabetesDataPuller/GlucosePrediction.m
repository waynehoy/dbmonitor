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
static GlucosePrediction *classPrediction = nil;


// Poll the web server to get the latest set of alerts
+ (GlucosePrediction *) _refreshPredictionHelper
{
    NSURL *alertsUrl = [NSURL URLWithString:@"http://wotkit.sensetecnic.com/api/sensors/mike.glucose/data?beforeE=1"]; // TODO WKH new URL for predictions
    NSURLRequest *request = [NSURLRequest requestWithURL:alertsUrl];
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *predictJson = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSArray *ary = (NSArray *)[NSJSONSerialization JSONObjectWithData:predictJson options:0 error:&error];
    
    // Here we have an NSArray of NSDictionary objects representing the JSON response from the server
    // Turn the first one into a GlucosePrediction objects
    NSDictionary *dict = [ary firstObject];
        
    NSDate *time = [NSDate dateWithTimeIntervalSince1970:([[dict objectForKey:@"timestamp"] doubleValue]/1000)];
    double reading = [((NSString *)[dict objectForKey:@"value"]) doubleValue];
    NSString *msg = [dict objectForKey:@"value"];  // TODO WKH Change the key
        
    GlucosePrediction *predict = [[GlucosePrediction alloc] init];
    predict.time = time;
    predict.reading = reading;
    predict.msg = msg;
    
    classPrediction = predict;
    return classPrediction;
}


// Force a refresh of the alerts array
+ (GlucosePrediction *) refreshPrediction
{
    return [GlucosePrediction _refreshPredictionHelper];
}

// Get the existing alerts array
+ (GlucosePrediction *) prediction
{
    if (classPrediction == nil) {
        // Refresh it
        return [GlucosePrediction refreshPrediction];
    }
    return classPrediction;
}

//// Override the compare method to allow sorting by time
//- (NSComparisonResult)compare:(Alert *)anotherAlert
//{
//    return [self.time compare:anotherAlert.time];
//}
//

@end
