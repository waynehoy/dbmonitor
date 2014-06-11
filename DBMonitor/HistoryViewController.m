//
//  HistoryViewController.m
//  DBMonitor
//
//  Created by Lorenzo Bertucci on 2014-06-02.
//  Copyright (c) 2014 Wayne Hoy. All rights reserved.
//

#import "HistoryViewController.h"
#import "GlucoseLevelList.h"
#import "GlucoseLevel.h"
#import "GlucosePredictionList.h"
#import "GlucosePrediction.h"

#import "CorePlot-CocoaTouch.h"


static const NSString* GRAPH_HIGHLIGHT_ID = @"GRAPH_HIGHLIGHT_ID";
static const NSString* GRAPH_ALL_ID = @"GRAPH_ALL_ID";


@interface HistoryViewController ()

- (void) _refreshPredictionHelper;
- (void) _refreshGlucoseDataHelper;
@end



@implementation HistoryViewController
{
    NSArray *myGlucoseLevels;
    NSArray *myGlucoseExtremes;
}

@synthesize hostView = _hostView;
@synthesize selectedTheme = _selectedTheme;

@synthesize graphView;
@synthesize date1;
@synthesize date2;
@synthesize date3;

@synthesize dataPt1;
@synthesize dataPt2;
@synthesize dataPt3;

@synthesize lastDataPt;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        myGlucoseLevels = nil;
        myGlucoseExtremes = nil;

    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    

    // Do any additional setup after loading the view.
    myGlucoseLevels = nil;
    myGlucoseExtremes = nil;
    [self _refreshGlucoseDataHelper];
    [self _refreshPredictionHelper];
    
    [self refreshLastUpdatedLabel];
    
#if 0
    // ****************************************************************************
    // I think this entire section is superceded by _updatePredictionHelper????
    //
    // ****************************************************************************
    
    NSArray* dateLabels = [NSArray arrayWithObjects:
                           date3,
                           date2,
                           date1,
                           nil];
    
    NSUInteger i = 2;
//    NSAssert([[self data] count] > 2, @"valid"); // TODO fixme, yes this is dumb
    for(UILabel* l in dateLabels)
    {
        // l.text = @"June 2 @ 9:00am";
        NSDate* date = [[[self data] objectAtIndex:[[self data] count] - 1 - i] time];
        l.text = [NSDateFormatter localizedStringFromDate:date
                                                dateStyle:NSDateFormatterShortStyle
                                                timeStyle:NSDateFormatterShortStyle];
        i--;
    }
    
    NSArray* dataLabels = [NSArray arrayWithObjects:
                           dataPt3,
                           dataPt2,
                           dataPt1,
                           nil];
    i = 2;
    float level = 0;
    for(UILabel* l in dataLabels)
    {
        // l.text = @"9.2 mmol/L -- BG low";
        level = [[[self data] objectAtIndex:[[self data] count] - 1 - i] glucose];
        l.text = [NSString stringWithFormat:@"%.1f mmol/L", level];
        i--;
    }

    lastDataPt.text = [NSString stringWithFormat:@"%.1f" , level];
#endif
}

-(void)refreshLastUpdatedLabel
{
    GlucoseLevel *lastLevel = [[[GlucoseLevelList sharedInstance] sortedGlucose] lastObject];
    self.outLastUpdateLabel.text = [NSString stringWithFormat:@"Last Updated:\n%@",
                                    [NSDateFormatter localizedStringFromDate:lastLevel.time
                                                                   dateStyle:NSDateFormatterShortStyle
                                                                   timeStyle:NSDateFormatterShortStyle]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // The plot is initialized here, since the view bounds have not transformed for landscape until now
    [self initPlot];
}

// *********************************************************************
//
//  Core Plot Data Source methods
//
// *********************************************************************

// Returns the NSTimeInterval object representing the currently
// selected time period from the segemented control
// NSTimeInterval is in SECONDS
//
- (NSTimeInterval) _selectedDateOffset
{
    NSTimeInterval offset = 0.0;
    
    // Get the selected segment
    switch (self.outSelectedTimePeriod.selectedSegmentIndex)
    {
        case 0: offset = -3 * 60 * 60;
            break;
        case 1: offset = -6 * 60 * 60;
            break;
        case 2: offset = -12 * 60 * 60;
            break;
        case 3: offset = -24 * 60 * 60;
            break;
    }

    return offset;
}

-(CPTLayer*)dataLabelForPlot:(CPTPlot*)plot
                 recordIndex:(NSUInteger)index
{
    if(plot.identifier == GRAPH_HIGHLIGHT_ID)
    {
        GlucoseLevel *currLevel = [myGlucoseExtremes objectAtIndex:index];
        
        CPTMutableTextStyle *hitAnnotationTextStyle = [CPTMutableTextStyle textStyle];
        hitAnnotationTextStyle.color = [CPTColor whiteColor];
        hitAnnotationTextStyle.fontSize = 9.0f;
        hitAnnotationTextStyle.fontName = @"Helvetica";

        CPTTextLayer* textLayer = [[CPTTextLayer alloc] initWithText:[NSString stringWithFormat:@"%.1f", currLevel.glucose]
                                                               style:hitAnnotationTextStyle];
        return textLayer;
    }
    
    return nil;// (id)[NSNull null];
}

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    if(plot.identifier == GRAPH_HIGHLIGHT_ID)
        return 2;
    
    return [myGlucoseLevels count];

//    NSLog(@"Number of data points is %d", numPoints);

    
//    NSUInteger count = [self data].count;
//    if(count > MAXCOUNT)
//        return MAXCOUNT;
//    return count;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot
                     field:(NSUInteger)fieldEnum
               recordIndex:(NSUInteger)index
{
    NSUInteger count = [self numberOfRecordsForPlot:plot];
    
    GlucoseLevel *currLevel = nil;
    NSArray *dataList = nil;
    if(plot.identifier == GRAPH_HIGHLIGHT_ID) {
        dataList = myGlucoseExtremes;
        currLevel = [dataList objectAtIndex:index];
        NSLog(@"CurrLevel Extreme is %@", [currLevel description]);
    }
    else {
        dataList = myGlucoseLevels;
        currLevel = [myGlucoseLevels objectAtIndex:index];
    }

    switch (fieldEnum) {
        case CPTScatterPlotFieldX:
            
            if (index < count) {
                // Assume the numerical range of the X axis is 0.0 to 1.0
                // And the minTime is at 0.0 and the maxTime is at 1.0
                GlucoseLevel *firstObj = [myGlucoseLevels firstObject];
                GlucoseLevel *lastObj = [myGlucoseLevels lastObject];
                double minTime = (double)[firstObj.time timeIntervalSince1970];
                double maxTime = (double)[lastObj.time timeIntervalSince1970];
                
                NSLog(@"Start Time is %@, End Time is %@", [firstObj.time description], [lastObj.time description]);
                
                double timeRange = maxTime - minTime;
                double curTime = (double)[[currLevel time] timeIntervalSince1970];
                // percentage of value along axis length
                double xValue = ((curTime - minTime) / timeRange); //*1000;
                                                                   // NSLog(@"x value is %f", xValue);
                NSLog(@"Plotting X at %f", xValue);
                
                return [NSNumber numberWithDouble:xValue];
                }
            break;
            
        case CPTScatterPlotFieldY:
            if (index < count)
                {
                NSLog(@"y value is %f", [[dataList objectAtIndex:index] glucose]);
                    
                return [NSNumber numberWithFloat:[currLevel glucose]];
                }
            break;
    }
    return [NSDecimalNumber zero];
}

//-(CPTLayer *)dataLabelForPlot:(CPTPlot*)plot recordIndex:(NSUInteger)index
//{
//    return nil;
//}


-(NSString *)legendTitleForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index {
    return @"";
}



// *********************************************************************
//
//  Core Plot chart setup methods
//
// *********************************************************************

- (IBAction)actTimePeriodChanged:(id)sender {
    UISegmentedControl *seg = (UISegmentedControl *)sender;
    NSLog(@"Sender is %@", [seg description]);
    NSLog(@"Selected Index is %d", (int)[seg selectedSegmentIndex]);
    
    // Just reload the graph
    [self initPlot];
}

- (IBAction)actRefresh:(id)sender
{
    [self _refreshGlucoseDataHelper];
    [self _refreshPredictionHelper];

    [self initPlot];
    [self refreshLastUpdatedLabel];

    // TODO replace with a real popup message based on the last prediction, if it's relevant
    //[self performSelector:@selector(displayAlert:) withObject:nil afterDelay:4];
}

-(void)displayAlert:(id)arg
{
    GlucosePrediction* prediction = [[[GlucosePredictionList sharedInstance] sortedPredictions] lastObject];
    
    NSString* custom = nil;
    if(prediction.deviation > 0){
        custom = [NSString stringWithFormat:@"Your glucose levels need attention. It has an upward deviation, estimated danger time:%.1f", prediction.timeToGo];
    }else if(prediction.deviation<0){
        custom = [NSString stringWithFormat:@"Your glucose levels need attention. It has a downward deviation, estimated danger time:%.1f", prediction.timeToGo];
    }
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Blood Glucose Warning"
                                                    message:custom
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}

-(void)initPlot
{
    // Set the instance variable array of datapoints to the appropriate subset of glucose data points
    //
    // TODO setting the "current time" as the known last observation from the Hackathon
    // - We haven't been gathering data since, so last X hours would be empty!
    NSDate *nowDate = [NSDate dateWithTimeIntervalSince1970: (1401821877818.0/1000.0)];
    
    NSTimeInterval offset = [self _selectedDateOffset];
    NSDate *startDate = [nowDate dateByAddingTimeInterval:offset];
    
    myGlucoseLevels = [[GlucoseLevelList sharedInstance] glucoseLevelsSince:startDate];
    
    // Same thing, get the extremes
    myGlucoseExtremes = [[GlucoseLevelList sharedInstance] glucoseExtremesSince:startDate];
    
    // Update the chart!
    [self configureHost];
    [self configureGraph];
    [self configureChart];
    [self configureLegend];
    return;
}

-(void)configureHost
{
    // 1 - Set up view frame
    CGRect parentRect = self.graphView.bounds;
    //    CGSize toolbarSize = self.toolbar.bounds.size;
    parentRect = CGRectMake(parentRect.origin.x,
                            (parentRect.origin.y+0),
                            //+ toolbarSize.height),
                            parentRect.size.width,
                            (parentRect.size.height-0));
    //- toolbarSize.height));
    // 2 - Create host view
    self.hostView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:parentRect];
    self.hostView.allowPinchScaling = NO;
    [self.graphView addSubview:self.hostView];
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

    [graph setPaddingRight:30.0f];
    [graph setPaddingLeft:30.0f];
//    [graph setPaddingBottom:30.0f];

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
    aaplPlot.identifier = GRAPH_ALL_ID;
    
    
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
    
    // Get the first and last times in the segmented dataset, should be in myGlucoseLevels instance variable already
    NSArray* dates = [NSArray arrayWithObjects:[[myGlucoseLevels firstObject] time], [[myGlucoseLevels lastObject] time], nil];
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
    highlightlPlot.identifier = GRAPH_HIGHLIGHT_ID;
    
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
    
    return;
}

-(void)configureLegend
{
    return;
}

// *********************************************************************************
//
//  Refresh Data Section
//
// *********************************************************************************

- (void) _refreshGlucoseDataHelper
{
    [[GlucoseLevelList sharedInstance] refresh];
    myGlucoseLevels = nil;
}


- (void) _refreshPredictionHelper
{
    NSArray *predictions = [[GlucosePredictionList sharedInstance] refresh];
    
    // 1- Update the most recent prediction
    GlucosePrediction *predict = [predictions lastObject];
    if (predict == nil)
    {
        // Hide the picture and the label
        self.outPredictionLabel.hidden = YES;
        self.outTrendImage.hidden = YES;
    }
    else {
        self.outPredictionLabel.hidden = NO;
        self.outPredictionLabel.text = [NSString stringWithFormat:@"%.1f minutes", predict.timeToGo];
        
        // Update the picture
        UIImage *image = nil;
        if (predict.deviation > 0) {
            image = [UIImage imageNamed:@"Upperlimit.png"];
        }
        else if (predict.deviation < 0) {
            image = [UIImage imageNamed:@"Lowerlimit.png"];
            
        }
        
        if (image != nil) {
            self.outTrendImage.image = image;
            CATransition *transition = [CATransition animation];
            transition.duration = 1.0f;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            transition.type = kCATransitionFade;
            
            [self.outTrendImage.layer addAnimation:transition forKey:nil];
        }
    }
    
    
    // 2- Update the last 3 preductions
    // Get the alerts, it's sorted in reverse order

    // Update the first label
    
    if ((predictions != nil) && ([predictions count] >= 1)) {
        predict = [predictions firstObject];
        self.date1.text = [NSDateFormatter localizedStringFromDate:predict.time
                                                         dateStyle:0
                                                         timeStyle:NSDateFormatterShortStyle];
        self.dataPt1.text = [NSString stringWithFormat:@"%@ : %.1f minutes",
                             (predict.deviation > 0) ? @"Upper Limit" : @"Lower Limit",
                                predict.timeToGo];
    }
    else {
        self.date1.hidden= YES;
        self.dataPt1.hidden = YES;
    }
    
    // Update the second label
    if ((predictions != nil) && ([predictions count] >= 2)) {
        predict = [predictions objectAtIndex:1];
        self.date2.text = [NSDateFormatter localizedStringFromDate:predict.time
                                                     dateStyle:0
                                                     timeStyle:NSDateFormatterShortStyle];
        self.dataPt2.text = [NSString stringWithFormat:@"%@ : %.1f minutes",
                             (predict.deviation > 0) ? @"Upper Limit" : @"Lower Limit",
                             predict.timeToGo];
    }
    else {
        self.date2.hidden= YES;
        self.dataPt2.hidden = YES;
    }
    
    // Update the third label
    if ((predictions != nil) && ([predictions count] >= 3)) {
        predict = [predictions objectAtIndex:2];
        self.date3.text = [NSDateFormatter localizedStringFromDate:predict.time
                                                     dateStyle:0
                                                     timeStyle:NSDateFormatterShortStyle];
        self.dataPt3.text = [NSString stringWithFormat:@"%@ : %.1f minutes",
                             (predict.deviation > 0) ? @"Upper Limit" : @"Lower Limit",
                             predict.timeToGo];
    }
    else {
        self.date3.hidden= YES;
        self.dataPt3.hidden = YES;
    }
}
@end
