//
//  HistoryViewController.h
//  DBMonitor
//
//  Created by Lorenzo Bertucci on 2014-06-02.
//  Copyright (c) 2014 Wayne Hoy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@class DiabetesDataPuller;



@interface HistoryViewController : UIViewController <CPTPlotDataSource>
{
    CPTXYGraph *myGraph;
}

@property (nonatomic, strong) CPTGraphHostingView *hostView;
@property (nonatomic, strong) CPTTheme *selectedTheme;

@property (nonatomic, strong) IBOutlet UILabel* date1;
@property (nonatomic, strong) IBOutlet UILabel* date2;
@property (nonatomic, strong) IBOutlet UILabel* date3;

@property (nonatomic, strong) IBOutlet UILabel* dataPt1;
@property (nonatomic, strong) IBOutlet UILabel* dataPt2;
@property (nonatomic, strong) IBOutlet UILabel* dataPt3;

@property (nonatomic, strong) IBOutlet UILabel* lastDataPt;
@property (nonatomic, strong) IBOutlet UIView* graphView;

@property (weak, nonatomic) IBOutlet UIImageView *outTrendImage;
@property (weak, nonatomic) IBOutlet UILabel *outLastUpdateLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *outSelectedTimePeriod;
- (IBAction)actTimePeriodChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *outPredictionLabel;
- (IBAction)actRefresh:(id)sender;

-(void)initPlot;
-(void)configureHost;
-(void)configureGraph;
-(void)configureChart;
-(void)configureLegend;
-(void)displayAlert:(id)arg;

@end
