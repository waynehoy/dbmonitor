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
// x- alerts  (4.5 - 7.5)
// x- one page app
// x- prettyness
// x- way to refresh graph / show variable time frames