//
//  GlucosePredictionList.m
//  DBMonitor
//
//  Created by Wayne Hoy on 2014-06-10.
//  Copyright (c) 2014 Wayne Hoy. All rights reserved.
//

#import "GlucosePredictionList.h"
#import "GlucosePrediction.h"

@interface GlucosePredictionList ()

- (NSArray *) _refreshPredictionsHelper;

@end

@implementation GlucosePredictionList
{
    NSURL *myUrl;
}

@synthesize sortedPredictions = _sortedPredictions;


static int classMaxPredictions = 20;

+ (void) setMaxPredictions: (int) max
{
    if (max > 0) {
        classMaxPredictions = max;
    }
}


//
// Singleton Accessor
//
+ (GlucosePredictionList *) sharedInstance
{
    static dispatch_once_t once;
    static GlucosePredictionList * sharedInstance = nil;
    
    dispatch_once(&once, ^{
        sharedInstance = [[GlucosePredictionList alloc] initWithUrl:
                          [NSURL URLWithString:
                           [NSString stringWithFormat:@"http://wotkit.sensetecnic.com/api/sensors/hackathon.prediction-test/data?beforeE=%d", classMaxPredictions]]];
    // TODO Production URL for predictions
//        [sharedInstance refreshPredictions];
    });
    
    //    sharedInstance = [[GlucoseLevelList alloc] initWithUrl:
    //                      [NSURL URLWithString:@"http://wotkit.sensetecnic.com/api/sensors/hackathon.glucose/data?beforeE=288"]];
    
    return sharedInstance;
}


//
// Initializer
//
- (GlucosePredictionList *) initWithUrl: (NSURL *) url
{
    self = [super init];
    if (self != nil) {
        myUrl = url;
    }

    return self;
}

//
// Force refresh
//
- (NSArray *) refresh
{
    return [self _refreshPredictionsHelper];
}


// Poll the web server to get the latest set of alerts
- (NSArray *) _refreshPredictionsHelper
{
    NSURLRequest *request = [NSURLRequest requestWithURL:myUrl];
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *predictJson = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSArray *ary = (NSArray *)[NSJSONSerialization JSONObjectWithData:predictJson options:0 error:&error];
    
    // Here we have an NSArray of NSDictionary objects representing the JSON response from the server
    // Turn the first one into a GlucosePrediction objects
    NSMutableArray *predictObjAry = [[NSMutableArray alloc] init];
    for (int i = 0; i < [ary count]; i++)
    {
        NSDictionary *dict = [ary objectAtIndex:i];
        
        NSDate *time = [NSDate dateWithTimeIntervalSince1970:([[dict objectForKey:@"timestamp"] doubleValue]/1000.0)];
        double deviation = [((NSString *)[dict objectForKey:@"deviation"]) doubleValue];
        double timeToGo = [((NSString *)[dict objectForKey:@"time_to_go"]) doubleValue];
        
        // If the deviation is zero, discard this
        if (deviation != 0)
        {
            GlucosePrediction *predict = [[GlucosePrediction alloc] init];
            predict.time = time;
            predict.deviation = deviation;
            predict.timeToGo = timeToGo;
            
            [predictObjAry addObject:predict];
        }
    }
    
    // Sort the array in time, store it in the class variable, and return
    NSSortDescriptor* sortOrder = [NSSortDescriptor sortDescriptorWithKey: @"self" ascending: NO];
    //    NSArray *sorted = [ary sortedArrayUsingSelector:@selector(compare:)];
    self.sortedPredictions = [predictObjAry sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortOrder]];
    
    NSAssert(self.sortedPredictions.count == predictObjAry.count, @"valid");
    //NSAssert(sorted.count == 144, @"valid");
    return self.sortedPredictions;
}


@end

