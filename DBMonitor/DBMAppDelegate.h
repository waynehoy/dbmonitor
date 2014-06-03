//
//  DBMAppDelegate.h
//  DBMonitor
//
//  Created by Wayne Hoy on 2014-06-01.
//  Copyright (c) 2014 Wayne Hoy. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DiabetesDataPuller;

@interface DBMAppDelegate : UIResponder <UIApplicationDelegate>
{
    NSArray* data;
    DiabetesDataPuller* ddp;
}
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) DiabetesDataPuller* ddp;
@property (nonatomic, strong) NSArray* data;

@end



// TODO:
// x- fix axes
// x- highlight data high/low
// x- history
// - alerts
// x- one page app
// - prettyness
// - way to refresh graph / show variable time frames