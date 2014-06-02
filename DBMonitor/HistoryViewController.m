//
//  HistoryViewController.m
//  DBMonitor
//
//  Created by Lorenzo Bertucci on 2014-06-02.
//  Copyright (c) 2014 Wayne Hoy. All rights reserved.
//

#import "HistoryViewController.h"

@interface HistoryViewController ()

@end

@implementation HistoryViewController

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
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    NSArray* dateLabels = [NSArray arrayWithObjects:
                           date1,
                           date2,
                           date3,
                           nil];
    
    for(UILabel* l in dateLabels)
    {
        l.text = @"June 2 @ 9:00am";
    }
    
    NSArray* dataLabels = [NSArray arrayWithObjects:
                           dataPt1,
                           dataPt2,
                           dataPt3,
                           nil];
    
    for(UILabel* l in dataLabels)
    {
        l.text = @"9.2 mmol/L -- BG low";
    }

    
    
    lastDataPt.text = [NSString stringWithFormat:@"Last Blood Glucose Reading:  %.1f mmol/L" , 9.2];
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

@end
