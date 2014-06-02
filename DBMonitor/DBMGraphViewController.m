//
//  DBMViewController.m
//  DBMonitor
//
//  Created by Wayne Hoy on 2014-06-01.
//  Copyright (c) 2014 Wayne Hoy. All rights reserved.
//

#import "DBMGraphViewController.h"
#import "CorePlot-CocoaTouch.h"

@interface DBMGraphViewController ()

@end

@implementation DBMGraphViewController

@synthesize hostView = _hostView;
@synthesize selectedTheme = _selectedTheme;

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

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return 10;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot
                     field:(NSUInteger)fieldEnum
               recordIndex:(NSUInteger)index
{
    switch (fieldEnum) {
        case CPTScatterPlotFieldX:
//            if (index < valueCount) {
                return [NSNumber numberWithUnsignedInteger:index];
  //          }
            break;
            
        case CPTScatterPlotFieldY:
                return [NSNumber numberWithUnsignedInteger:index*index];
            break;
    }
    return [NSDecimalNumber zero];
    
    
    
  //  return [NSNumber numberWithInt:index*2];
}

-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index
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
//    [graph applyTheme:[CPTTheme themeNamed:kCPTDarkGradientTheme]];
    self.hostView.hostedGraph = graph;
    // 2 - Set graph title
    NSString *title = @"Chart Title";
    graph.title = title;
    // 3 - Create and set text style
    CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
//    titleStyle.color = [CPTColor whiteColor];
    titleStyle.fontName = @"Helvetica";
    titleStyle.fontSize = 12.0f;
    graph.titleTextStyle = titleStyle;
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    graph.titleDisplacement = CGPointMake(0.0f, 10.0f);
    // 4 - Set padding for plot area
    [graph.plotAreaFrame setPaddingLeft:30.0f];
    [graph.plotAreaFrame setPaddingBottom:30.0f];
    // 5 - Enable user interactions for plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
    return;
}

-(void)configureChart
{
    // 1 - Get graph and plot space
    CPTGraph *graph = self.hostView.hostedGraph;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    // 2 - Create the three plots
    CPTScatterPlot *aaplPlot = [[CPTScatterPlot alloc] init];
    aaplPlot.dataSource = self;
    aaplPlot.identifier = 0;    // WKH TODO Enum for the plot ID (series)
    CPTColor *aaplColor = [CPTColor redColor];
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
    [plotSpace scaleToFitPlots:[NSArray arrayWithObjects:aaplPlot, nil]];
    CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
    [xRange expandRangeByFactor:CPTDecimalFromCGFloat(1.1f)];
    plotSpace.xRange = xRange;
    CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
    [yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.2f)];
    plotSpace.yRange = yRange;
    // 4 - Create styles and symbols
    CPTMutableLineStyle *aaplLineStyle = [aaplPlot.dataLineStyle mutableCopy];
    aaplLineStyle.lineWidth = 2.5;
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
