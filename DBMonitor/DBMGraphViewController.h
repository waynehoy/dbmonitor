//
//  DBMViewController.h
//  DBMonitor
//
//  Created by Wayne Hoy on 2014-06-01.
//  Copyright (c) 2014 Wayne Hoy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@class DiabetesDataPuller;

@interface DBMGraphViewController : UIViewController <CPTPlotDataSource>
{
    CPTXYGraph *myGraph;
    
    NSArray* data;
    DiabetesDataPuller* ddp;
}

@property (nonatomic, strong) CPTGraphHostingView *hostView;
@property (nonatomic, strong) CPTTheme *selectedTheme;

@property (nonatomic, strong) DiabetesDataPuller* ddp;
@property (nonatomic, strong) NSArray* data;

-(void)initPlot;
-(void)configureHost;
-(void)configureGraph;
-(void)configureChart;
-(void)configureLegend;

@end
