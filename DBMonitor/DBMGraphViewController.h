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
}

@property (nonatomic, strong) CPTGraphHostingView *hostView;
@property (nonatomic, strong) CPTTheme *selectedTheme;


-(void)initPlot;
-(void)configureHost;
-(void)configureGraph;
-(void)configureChart;
-(void)configureLegend;

@end
