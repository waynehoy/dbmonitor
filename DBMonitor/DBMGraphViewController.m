//
//  DBMViewController.m
//  DBMonitor
//
//  Created by Wayne Hoy on 2014-06-01.
//  Copyright (c) 2014 Wayne Hoy. All rights reserved.
//

#import "DBMGraphViewController.h"

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
    return [NSNumber numberWithInt:1];
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
    return;
}

-(void)configureGraph
{
    return;
}

-(void)configureChart
{
    return;
}

-(void)configureLegend
{
    return;
}

@end
