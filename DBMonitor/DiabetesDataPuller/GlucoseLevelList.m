//
//  GlucoseLevelList.m
//  DBMonitor
//
//  Created by Wayne Hoy on 2014-06-08.
//  Copyright (c) 2014 Wayne Hoy. All rights reserved.
//

#import "GlucoseLevelList.h"
#import "GlucoseLevel.h"

@interface GlucoseLevelList ()
- (NSArray *) _refreshGlucoseHelper;

@end

@implementation GlucoseLevelList
{
    NSURL *myUrl;
}


@synthesize minTime         = _minTime;
@synthesize minGlucose      = _minGlucose;
@synthesize maxTime         = _maxTime;
@synthesize maxGlucose      = _maxGlucose;
@synthesize sortedGlucose   = _sortedGlucose;


//
// Singleton Accessor
//
+ (GlucoseLevelList *)sharedInstance
{
    static dispatch_once_t once;
    static GlucoseLevelList * sharedInstance = nil;
    
    dispatch_once(&once, ^{
        sharedInstance = [[GlucoseLevelList alloc] initWithUrl:
                          [NSURL URLWithString:@"http://wotkit.sensetecnic.com/api/sensors/hackathon.glucose/data?beforeE=288"]];
        [sharedInstance refresh];
    });
    
//    sharedInstance = [[GlucoseLevelList alloc] initWithUrl:
//                      [NSURL URLWithString:@"http://wotkit.sensetecnic.com/api/sensors/hackathon.glucose/data?beforeE=288"]];
    
    return sharedInstance;
}


//
// Initializer
//
- (GlucoseLevelList *) initWithUrl: (NSURL *) url
{
    self = [super init];
    if (self != nil) {
        myUrl = url;
    }
    
    self.minTime = nil;
    self.minGlucose = 9999.9;
    self.maxTime = nil;
    self.maxGlucose = -9999.9;
    self.sortedGlucose = nil;
    
    return self;
}

//
// Force refresh
//
- (NSArray *) refresh
{
    return [self _refreshGlucoseHelper];
}

//
// Return a sorted array of all glucose level observations since a certain time
//
- (NSArray *)glucoseLevelsSince:(NSDate *)dateTime
{
    int i = 0;
    GlucoseLevel *level = nil;
    for(i = 0; i < [self.sortedGlucose count]; i++)
    {
        level = [self.sortedGlucose objectAtIndex:i];
        if ([dateTime compare:level.time] == NSOrderedAscending) {
            // This level object is after the passed time
            // Since the array is sorted ascending, this is the first one we want
            break;
        }
    }
    
    NSLog(@"Found %@ after %@ at index %d", [level description], [dateTime description], i);
    
    NSArray *subArray = [self.sortedGlucose subarrayWithRange:NSMakeRange(i, [self.sortedGlucose count]-i)];
    return subArray;
}


//
// Get the extreme glucose values in the entire set
//
- (NSArray *) glucoseExtremes
{
    GlucoseLevel* levelmin = [[GlucoseLevel alloc] init];
    levelmin.time = self.minTime;
    levelmin.glucose = self.minGlucose;
    
    GlucoseLevel* levelmax = [[GlucoseLevel alloc] init];
    levelmax.time = self.maxTime;
    levelmax.glucose = self.maxGlucose;
    
    return [NSArray arrayWithObjects:levelmin, levelmax, nil];
}

- (NSArray *) glucoseExtremesSince:(NSDate *)dateTime
{
    NSArray *subset = [self glucoseLevelsSince:dateTime];
    
    GlucoseLevel *levelMin = nil;
    GlucoseLevel *levelMax = nil;
    
    for (int i = 0; i < [subset count]; i++) {
        GlucoseLevel *level = [subset objectAtIndex:i];
        
        if ((levelMin == nil) || (level.glucose < levelMin.glucose)) {
            levelMin = level;
        }
        if ((levelMax == nil) || (level.glucose > levelMax.glucose)) {
            levelMax = level;
        }
    }
    
    return [NSArray arrayWithObjects:levelMin, levelMax, nil];
}

//
// Helper method to refresh the glucose level set
//
- (NSArray *) _refreshGlucoseHelper
{
    NSURLRequest    *request = [NSURLRequest requestWithURL:myUrl];
    NSURLResponse   *response = nil;
    NSError         *error = nil;
    NSData          *glucoseJson = [NSURLConnection sendSynchronousRequest:request
                                                         returningResponse:&response
                                                                     error:&error];
    
    NSObject        *obj = [NSJSONSerialization JSONObjectWithData:glucoseJson options:0 error:&error];
    
    NSArray         *ary = (NSArray *)obj;
    
    // Release the old array of glucose levels;
    self.sortedGlucose = nil;
    
    NSMutableArray *unsorted = [[NSMutableArray alloc] init];
    
    // Have retrieved the list of of glucose level observations from the server
    // The JSON format is an array of dictionaries
    // Loop through, and convert into a Set of GlucloseLevel objects
    //
    for (NSDictionary *dic in ary)
    {
        float value =  [[dic objectForKey:@"value"] floatValue];
        
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
        [unsorted addObject:level];
        
        // Record the new minimums and maximums
        if ((self.maxTime == nil) || ([self.maxTime compare:level.time] == NSOrderedAscending)) {
            self.maxTime = level.time;
        }
        if ((self.minTime == nil) || ([self.minTime compare:level.time] == NSOrderedDescending)) {
            self.maxTime = level.time;
        }
        if (self.maxGlucose < level.glucose) {
            self.maxGlucose = level.glucose;
        }
        if (self.minGlucose > level.glucose) {
            self.minGlucose = level.glucose;
        }
        
    }
    
    self.sortedGlucose = [unsorted sortedArrayUsingSelector:@selector(compare:)];
    NSAssert(self.sortedGlucose.count == unsorted.count, @"valid");
    //NSAssert(sorted.count == 144, @"valid");
    return self.sortedGlucose;
    
}


@end
