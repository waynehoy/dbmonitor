//
//  Alert.m
//  DiabetesDataPuller
//
//  Created by Tim Orbasido on 2014-06-02.
//  Copyright (c) 2014 Group4. All rights reserved.
//

#import "Alert.h"

@implementation Alert

@synthesize time = _time;
@synthesize priority = _priority;
@synthesize title = _title;
@synthesize msg = _msg;


// Static singleton accessor methods and preferences
static NSArray *classAlertsArray = nil;
static int classMaxAlerts = 20;

+ (void) setMaxAlerts: (int) max
{
    if (max > 0) {
        classMaxAlerts = max;
    }
}


// Poll the web server to get the latest set of alerts
+ (NSArray *) _refreshAlertsHelper
{
    NSURL *alertsUrl = [NSURL URLWithString:
                        [NSString stringWithFormat:@"http://wotkit.sensetecnic.com/api/sensors/mike.glucose/data?beforeE=%d",classMaxAlerts]];
    NSURLRequest *request = [NSURLRequest requestWithURL:alertsUrl];
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *alertsJson = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSArray *ary = (NSArray *)[NSJSONSerialization JSONObjectWithData:alertsJson options:0 error:&error];

    // Here we have an NSArray of NSDictionary objects representing the JSON response from the server
    // Turn it into an array of Alert objects
    NSMutableArray *alertObjAry = [[NSMutableArray alloc] init];
    for (int i = 0; i < [ary count]; i++) {
        NSDictionary *dict = [ary objectAtIndex:i];
        
        NSDate *time = [NSDate dateWithTimeIntervalSince1970:([[dict objectForKey:@"timestamp"] doubleValue]/1000)];
        NSString *priority = [dict objectForKey:@"value"];
        NSString *title = [dict objectForKey:@"value"];
        NSString *msg = [dict objectForKey:@"value"];
        
        Alert *alert = [[Alert alloc] init];
        alert.time = time;
        alert.priority = priority;
        alert.title = title;
        alert.msg = msg;
        
        [alertObjAry addObject:alert];
    }
    

    // Sort the array in time, store it in the class variable, and return
    NSSortDescriptor* sortOrder = [NSSortDescriptor sortDescriptorWithKey: @"self" ascending: NO];
//    NSArray *sorted = [ary sortedArrayUsingSelector:@selector(compare:)];
    NSArray *sorted = [alertObjAry sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortOrder]];
    
    NSAssert(sorted.count == alertObjAry.count, @"valid");
    classAlertsArray = sorted;
    //NSAssert(sorted.count == 144, @"valid");
    return classAlertsArray;
}


// Force a refresh of the alerts array
+ (NSArray *) refreshAlertsArray
{
    return [Alert _refreshAlertsHelper];
}

// Get the existing alerts array
+ (NSArray *) alertsArray
{
    if (classAlertsArray == nil) {
        // Refresh it
        return [Alert refreshAlertsArray];
    }
    return classAlertsArray;
}

// Override the compare method to allow sorting by time
- (NSComparisonResult)compare:(Alert *)anotherAlert
{
    return [self.time compare:anotherAlert.time];
}


@end
