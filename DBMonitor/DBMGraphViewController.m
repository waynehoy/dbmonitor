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

-(NSArray*)data;
-(DiabetesDataPuller*)ddp;

@end


static const NSString* GRAPH_HIGHLIGHT_ID = @"GRAPH_HIGHLIGHT_ID";
static const NSString* GRAPH_ALL_ID = @"GRAPH_ALL_ID";


@implementation DBMGraphViewController

@synthesize hostView = _hostView;
@synthesize selectedTheme = _selectedTheme;

-(NSArray*)data
{
    return (NSArray*)[((id)[[UIApplication sharedApplication] delegate]) data];
}

-(DiabetesDataPuller*)ddp
{
    return [((id)[[UIApplication sharedApplication] delegate]) ddp];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	// Do any additional setup after loading the view, typically from a nib.
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
    if(plot.identifier == GRAPH_HIGHLIGHT_ID)
        return 2;
    
    NSUInteger count = [self data].count;
    if(count > MAXCOUNT)
        return MAXCOUNT;
    return count;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot
                     field:(NSUInteger)fieldEnum
               recordIndex:(NSUInteger)index
{
    NSUInteger count = [self numberOfRecordsForPlot:plot];
    NSArray* dataPts = [self data];
    
    switch (fieldEnum) {
        case CPTScatterPlotFieldX:

            if(plot.identifier == GRAPH_HIGHLIGHT_ID)
            {
                dataPts = [[self ddp] getGlucoseExtremes];
            }
            
            if (index < count)
            {
                // Assume the numerical range of the X axis is 0.0 to 1.0
                // And the minTime is at 0.0 and the maxTime is at 1.0
                double minTime = (double)[[self ddp].startTime timeIntervalSince1970];
                double maxTime = (double)[[self ddp].endTime timeIntervalSince1970];

                double timeRange = maxTime - minTime;
                double curTime = (double)[[[dataPts objectAtIndex:index] time] timeIntervalSince1970];
            
                // percentage of value along axis length
                double xValue = ((curTime - minTime) / timeRange); //*1000;
                // NSLog(@"x value is %f", xValue);
            
                return [NSNumber numberWithDouble:xValue];
            }
            break;
            
        case CPTScatterPlotFieldY:
            if(plot.identifier == GRAPH_HIGHLIGHT_ID)
            {
                dataPts = [[self ddp] getGlucoseExtremes];
            }

            if (index < count)
            {
                //NSLog(@"y value is %f", [[self.data objectAtIndex:index] glucose]);
                return [NSNumber numberWithFloat:[[dataPts objectAtIndex:index] glucose]];
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
    titleStyle.fontName = @"Helvetica-Bold";
    titleStyle.fontSize = 10.0f;
    graph.titleTextStyle = titleStyle;
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    graph.titleDisplacement = CGPointMake(0.0f, 10.0f);
    
    // 4 - Set padding for plot area
    [graph.plotAreaFrame setPaddingRight:50.0f];
    [graph.plotAreaFrame setPaddingLeft:50.0f];
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
    aaplPlot.identifier = GRAPH_ALL_ID;    // WKH TODO Enum for the plot ID (series)
    
    
    CPTColor *aaplColor = [CPTColor colorWithComponentRed:0.168f green:0.547f blue:0.54f alpha:0.5f];
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    [graph addPlot:aaplPlot toPlotSpace:plotSpace];

    
    CGFloat xMin = 0.0f;
    CGFloat xMax = 1.0;
    CGFloat yMin = 0.0f;
    CGFloat yMax = 33.0f;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xMin) length:CPTDecimalFromFloat(xMax)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(yMin) length:CPTDecimalFromFloat(yMax)];

    
    // 1 - Configure styles
    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
    axisTitleStyle.color = [CPTColor whiteColor];
    axisTitleStyle.fontName = @"Helvetica-Bold";
    axisTitleStyle.fontSize = 10.0f;
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 2.0f;
    axisLineStyle.lineColor = [[CPTColor whiteColor] colorWithAlphaComponent:1];

    // 2 - Get the graph's axis set
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;

    // 3 - Configure the x-axis
    axisSet.xAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
    //axisSet.xAxis.title = @"Time (12 hour interval)";
    axisSet.xAxis.titleTextStyle = axisTitleStyle;
    axisSet.xAxis.titleOffset = 10.0f;
    axisSet.xAxis.axisLineStyle = axisLineStyle;

    axisSet.xAxis.labelTextStyle = axisTitleStyle;
    axisSet.xAxis.majorTickLineStyle = axisLineStyle;
    axisSet.xAxis.majorTickLength = 4.0f;
    axisSet.xAxis.tickDirection = CPTSignNegative;
    
    CGFloat dateCount = 2;
    NSMutableSet *xLabels = [NSMutableSet setWithCapacity:dateCount];
    NSMutableSet *xLocations = [NSMutableSet setWithCapacity:dateCount];
    NSInteger i = 0;
    NSArray* dates = [NSArray arrayWithObjects:[self ddp].startTime, [self ddp].endTime, nil];
    for (NSDate* date in dates)
    {
        NSString* d = [NSDateFormatter localizedStringFromDate:date
                                                     dateStyle:NSDateFormatterShortStyle
                                                     timeStyle:NSDateFormatterShortStyle];

        CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:d  textStyle:axisSet.xAxis.labelTextStyle];
        CGFloat location = i++;
        label.tickLocation = CPTDecimalFromCGFloat(location);
        label.offset = axisSet.xAxis.majorTickLength;
        if (label)
        {
            [xLabels addObject:label];
            [xLocations addObject:[NSNumber numberWithFloat:location]];
        }
    }
    axisSet.xAxis.axisLabels = xLabels;
    axisSet.xAxis.majorTickLocations = xLocations;
    
    // 4 - Configure the y-axis
    axisSet.yAxis.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
    //axisSet.yAxis.title = @"Blood Glucose (mmol/L)";
    axisSet.yAxis.titleTextStyle = axisTitleStyle;
    axisSet.yAxis.labelTextStyle = axisTitleStyle;
    axisSet.yAxis.titleOffset = 5.0f;
    axisSet.yAxis.axisLineStyle = axisLineStyle;

    
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

    
    
    //
    // secondary plot (highlights -- only ever two data pts for min/max)
    //
    
    CPTScatterPlot *highlightlPlot = [[CPTScatterPlot alloc] init];
    highlightlPlot.dataSource = self;
    highlightlPlot.identifier = GRAPH_HIGHLIGHT_ID;    // WKH TODO Enum for the plot ID (series)
    
    CPTColor *highlightColor = [CPTColor colorWithComponentRed:1.f green:1.f blue:1.f alpha:0.5f];
    [graph addPlot:highlightlPlot toPlotSpace:plotSpace];
    
    // 4 - Create styles and symbols
    CPTMutableLineStyle *highlightLineStyle = [highlightlPlot.dataLineStyle mutableCopy];
    highlightLineStyle.lineWidth = 0.0;
    highlightLineStyle.lineColor = highlightColor;
    highlightlPlot.dataLineStyle = highlightLineStyle;
    CPTMutableLineStyle *highlightSymbolLineStyle = [CPTMutableLineStyle lineStyle];
    highlightSymbolLineStyle.lineColor = highlightColor;
    CPTPlotSymbol *highlightSymbol = [CPTPlotSymbol trianglePlotSymbol];
    highlightSymbol.fill = [CPTFill fillWithColor:highlightColor];
    highlightSymbol.lineStyle = highlightSymbolLineStyle;
    highlightSymbol.size = CGSizeMake(6.0f, 6.0f);
    highlightlPlot.plotSymbol = highlightSymbol;
    
    
//    
//    static CPTMutableTextStyle *style = nil;
//    if (!style) {
//        style = [CPTMutableTextStyle textStyle];
//        style.color= [CPTColor yellowColor];
//        style.fontSize = 16.0f;
//        style.fontName = @"Helvetica-Bold";
//    }
//    // 3 - Create annotation, if necessary
//    NSNumber *price = [self numberForPlot:plot field:CPTBarPlotFieldBarTip recordIndex:index];
//    if (!self.priceAnnotation) {
//        NSNumber *x = [NSNumber numberWithInt:0];
//        NSNumber *y = [NSNumber numberWithInt:0];
//        NSArray *anchorPoint = [NSArray arrayWithObjects:x, y, nil];
//        self.priceAnnotation = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:plot.plotSpace anchorPlotPoint:anchorPoint];
//    }
//    // 4 - Create number formatter, if needed
//    static NSNumberFormatter *formatter = nil;
//    if (!formatter) {
//        formatter = [[NSNumberFormatter alloc] init];
//        [formatter setMaximumFractionDigits:2];
//    }
//    // 5 - Create text layer for annotation
//    NSString *priceValue = [formatter stringFromNumber:price];
//    CPTTextLayer *textLayer = [[CPTTextLayer alloc] initWithText:priceValue style:style];
//    self.priceAnnotation.contentLayer = textLayer;
//    // 6 - Get plot index based on identifier
//    NSInteger plotIndex = 0;
//    if ([plot.identifier isEqual:CPDTickerSymbolAAPL] == YES) {
//        plotIndex = 0;
//    } else if ([plot.identifier isEqual:CPDTickerSymbolGOOG] == YES) {
//        plotIndex = 1;
//    } else if ([plot.identifier isEqual:CPDTickerSymbolMSFT] == YES) {
//        plotIndex = 2;
//    }
//    // 7 - Get the anchor point for annotation
//    CGFloat x = index + CPDBarInitialX + (plotIndex * CPDBarWidth);
//    NSNumber *anchorX = [NSNumber numberWithFloat:x];
//    CGFloat y = [price floatValue] + 40.0f;
//    NSNumber *anchorY = [NSNumber numberWithFloat:y];
//    self.priceAnnotation.anchorPlotPoint = [NSArray arrayWithObjects:anchorX, anchorY, nil];
//    // 8 - Add the annotation 
//    [plot.graph.plotAreaFrame.plotArea addAnnotation:self.priceAnnotation];
//    
    
    return;
}

-(void)configureLegend
{
    return;
}

@end
