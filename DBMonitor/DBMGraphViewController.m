//
//  DBMViewController.m
//  DBMonitor
//
//  Created by Wayne Hoy on 2014-06-01.
//  Copyright (c) 2014 Wayne Hoy. All rights reserved.
//

#import "DBMGraphViewController.h"
#import "CorePlot-CocoaTouch.h"
#import "DiabetesDataPuller.h"
#import "GlucoseLevel.h"



@interface DBMGraphViewController ()

@end



@implementation DBMGraphViewController

@synthesize hostView = _hostView;
@synthesize selectedTheme = _selectedTheme;

@synthesize data = data;
@synthesize ddp = ddp;


- (void)viewDidLoad
{
    [super viewDidLoad];

	// Do any additional setup after loading the view, typically from a nib.
    self.ddp = [[DiabetesDataPuller alloc] init];
    self.data = [ddp getGlucose:0];
    NSLog(@"data = %@", self.data);
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // The plot is initialized here, since the view bounds have not transformed for landscape until now
    [self initPlot];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// *********************************************************************
//
//  Core Plot Data Source methods
//
// *********************************************************************
#define MAXCOUNT ((60 /*min/h*/ / 5 /*min/datapt*/) * 12 /*hours*/) /* data pts per 3 hour interval */
- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    NSUInteger count = self.data.count;
    if(count > MAXCOUNT)
        return MAXCOUNT;
    return count;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot
                     field:(NSUInteger)fieldEnum
               recordIndex:(NSUInteger)index
{
    NSUInteger count = [self numberOfRecordsForPlot:plot];
                
    switch (fieldEnum) {
        case CPTScatterPlotFieldX:
            if (index < count)
            {
                // Assume the numerical range of the X axis is 0.0 to 1.0
                // And the minTime is at 0.0 and the maxTime is at 1.0
                double minTime = (double)[self.ddp.startTime timeIntervalSince1970];
                double maxTime = (double)[self.ddp.endTime timeIntervalSince1970];

                double timeRange = maxTime - minTime;
                double curTime = (double)[[[self.data objectAtIndex:index] time] timeIntervalSince1970];
            
                // percentage of value along axis length
                double xValue = ((curTime - minTime) / timeRange); //*1000;
                // NSLog(@"x value is %f", xValue);
            
                return [NSNumber numberWithDouble:xValue];
            }
            break;
            
        case CPTScatterPlotFieldY:
            if (index < count)
            {
                //NSLog(@"y value is %f", [[self.data objectAtIndex:index] glucose]);
                return [NSNumber numberWithFloat:[[self.data objectAtIndex:index] glucose]];
            }
            break;
    }
    return [NSDecimalNumber zero];
}

-(CPTLayer *)dataLabelForPlot:(CPTPlot*)plot recordIndex:(NSUInteger)index
{
    return nil;
}


-(NSString *)legendTitleForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index {
    return @"";
}



// *********************************************************************
//
//  Core Plot chart setup methods
//
// *********************************************************************

-(void)initPlot
{
    [self configureHost];
    [self configureGraph];
    [self configureChart];
    [self configureLegend];
    return;
}

-(void)configureHost
{
    // 1 - Set up view frame
    CGRect parentRect = self.view.bounds;
//    CGSize toolbarSize = self.toolbar.bounds.size;
    parentRect = CGRectMake(parentRect.origin.x,
                            (parentRect.origin.y+5),
                             //+ toolbarSize.height),
                            parentRect.size.width,
                            (parentRect.size.height-30));
    //- toolbarSize.height));
    // 2 - Create host view
    self.hostView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:parentRect];
    self.hostView.allowPinchScaling = NO;
    [self.view addSubview:self.hostView];
    return;
}

-(void)configureGraph
{
    // 1 - Create the graph
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
    [graph applyTheme:[CPTTheme themeNamed:kCPTDarkGradientTheme]];
    self.hostView.hostedGraph = graph;
    
    // 2 - Set graph title
    NSString *title = @"Blood Glucose Level (mmol/L) vs. Time";
    graph.title = title;
    
    // 3 - Create and set text style
    CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
    titleStyle.color = [CPTColor whiteColor];
    titleStyle.fontName = @"Helvetica";
    titleStyle.fontSize = 10.0f;
    graph.titleTextStyle = titleStyle;
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    graph.titleDisplacement = CGPointMake(0.0f, 10.0f);
    
    // 4 - Set padding for plot area
    [graph.plotAreaFrame setPaddingLeft:30.0f];
    [graph.plotAreaFrame setPaddingBottom:30.0f];
    
    // 5 - Enable user interactions for plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = NO;
    return;
}

-(void)configureChart
{
    // 1 - Get graph and plot space
    CPTGraph *graph = self.hostView.hostedGraph;
    
    // 2 - Create the three plots
    CPTScatterPlot *aaplPlot = [[CPTScatterPlot alloc] init];
    aaplPlot.dataSource = self;
    aaplPlot.identifier = 0;    // WKH TODO Enum for the plot ID (series)
    
    //id beginColor   = [CPTColor colorWithComponentRed:0.168f green:0.547f blue:0.54f alpha:0.5f];
    //id endColor     = [CPTColor colorWithComponentRed:0.0f green:0.0f blue:0.0f alpha:0.5f];
    //[aaplPlot setAreaFill:[CPTFill fillWithGradient:[CPTGradient gradientWithBeginningColor:beginColor
    //                                                                             endingColor:endColor]]];
    //NSDecimalNumber *intermediateNumber = [[NSDecimalNumber alloc] initWithFloat:0.0];
    //NSDecimal decimal = [intermediateNumber decimalValue];
    //[aaplPlot setAreaBaseValue:decimal];
    
    CPTColor *aaplColor = [CPTColor colorWithComponentRed:0.168f green:0.547f blue:0.54f alpha:0.5f];
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    [graph addPlot:aaplPlot toPlotSpace:plotSpace];

    
//    CPTScatterPlot *googPlot = [[CPTScatterPlot alloc] init];
//    googPlot.dataSource = self;
//    googPlot.identifier = CPDTickerSymbolGOOG;
//    CPTColor *googColor = [CPTColor greenColor];
//    [graph addPlot:googPlot toPlotSpace:plotSpace];
//    CPTScatterPlot *msftPlot = [[CPTScatterPlot alloc] init];
//    msftPlot.dataSource = self;
//    msftPlot.identifier = CPDTickerSymbolMSFT;
//    CPTColor *msftColor = [CPTColor blueColor];
//    [graph addPlot:msftPlot toPlotSpace:plotSpace];

    // 3 - Set up plot space
//    [plotSpace scaleToFitPlots:[NSArray arrayWithObjects:aaplPlot, nil]];
//    CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
//    [xRange expandRangeByFactor:CPTDecimalFromCGFloat(1.1f)];
//    plotSpace.xRange = xRange;
//    CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
//    [yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.2f)];
//    plotSpace.yRange = yRange;

    
    CGFloat xMin = 0.0f;
    CGFloat xMax = 1.0;
    CGFloat yMin = 0.0f;
    CGFloat yMax = 33.0f;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xMin) length:CPTDecimalFromFloat(xMax)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(yMin) length:CPTDecimalFromFloat(yMax)];

//    // 1 - Configure styles
//    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
//    axisTitleStyle.color = [CPTColor whiteColor];
//    axisTitleStyle.fontName = @"Helvetica-Bold";
//    axisTitleStyle.fontSize = 12.0f;
//    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
//    axisLineStyle.lineWidth = 2.0f;
//    axisLineStyle.lineColor = [[CPTColor whiteColor] colorWithAlphaComponent:1];
//
//    // 2 - Get the graph's axis set
//    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
//
//    // 3 - Configure the x-axis
//    axisSet.xAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
//    axisSet.xAxis.title = @"Days of Week (Mon - Fri)";
//    axisSet.xAxis.titleTextStyle = axisTitleStyle;
//    axisSet.xAxis.titleOffset = 10.0f;
//    axisSet.xAxis.axisLineStyle = axisLineStyle;
//
//    // 4 - Configure the y-axis
//    axisSet.yAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
//    axisSet.yAxis.title = @"Price";
//    axisSet.yAxis.titleTextStyle = axisTitleStyle;
//    axisSet.yAxis.titleOffset = 5.0f;
//    axisSet.yAxis.axisLineStyle = axisLineStyle;

    
    // 4 - Create styles and symbols
    CPTMutableLineStyle *aaplLineStyle = [aaplPlot.dataLineStyle mutableCopy];
    aaplLineStyle.lineWidth = 0.0;//2.5;
    aaplLineStyle.lineColor = aaplColor;
    aaplPlot.dataLineStyle = aaplLineStyle;
    CPTMutableLineStyle *aaplSymbolLineStyle = [CPTMutableLineStyle lineStyle];
    aaplSymbolLineStyle.lineColor = aaplColor;
    CPTPlotSymbol *aaplSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    aaplSymbol.fill = [CPTFill fillWithColor:aaplColor];
    aaplSymbol.lineStyle = aaplSymbolLineStyle;
    aaplSymbol.size = CGSizeMake(6.0f, 6.0f);
    aaplPlot.plotSymbol = aaplSymbol;

    
    
//    CPTMutableLineStyle *googLineStyle = [googPlot.dataLineStyle mutableCopy];
//    googLineStyle.lineWidth = 1.0;
//    googLineStyle.lineColor = googColor;
//    googPlot.dataLineStyle = googLineStyle;
//    CPTMutableLineStyle *googSymbolLineStyle = [CPTMutableLineStyle lineStyle];
//    googSymbolLineStyle.lineColor = googColor;
//    CPTPlotSymbol *googSymbol = [CPTPlotSymbol starPlotSymbol];
//    googSymbol.fill = [CPTFill fillWithColor:googColor];
//    googSymbol.lineStyle = googSymbolLineStyle;
//    googSymbol.size = CGSizeMake(6.0f, 6.0f);
//    googPlot.plotSymbol = googSymbol;
//    CPTMutableLineStyle *msftLineStyle = [msftPlot.dataLineStyle mutableCopy];
//    msftLineStyle.lineWidth = 2.0;
//    msftLineStyle.lineColor = msftColor;
//    msftPlot.dataLineStyle = msftLineStyle;
//    CPTMutableLineStyle *msftSymbolLineStyle = [CPTMutableLineStyle lineStyle];
//    msftSymbolLineStyle.lineColor = msftColor;
//    CPTPlotSymbol *msftSymbol = [CPTPlotSymbol diamondPlotSymbol];
//    msftSymbol.fill = [CPTFill fillWithColor:msftColor];
//    msftSymbol.lineStyle = msftSymbolLineStyle;
//    msftSymbol.size = CGSizeMake(6.0f, 6.0f);
//    msftPlot.plotSymbol = msftSymbol;
    return;
}

-(void)configureLegend
{
    return;
}

@end
