//
//  HistoryViewController.m
//  DBMonitor
//
//  Created by Lorenzo Bertucci on 2014-06-02.
//  Copyright (c) 2014 Wayne Hoy. All rights reserved.
//

#import "HistoryViewController.h"
#import "DiabetesDataPuller.h"
#import "GlucoseLevel.h"


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
    
    // Do any additional setup after loading the view.
    NSArray* dateLabels = [NSArray arrayWithObjects:
                           date3,
                           date2,
                           date1,
                           nil];
    
    NSUInteger i = 2;
    NSAssert([[self data] count] > 2, @"valid"); // fixme, yes this is dumb
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

    lastDataPt.text = [NSString stringWithFormat:@"Last Blood Glucose Reading:  %.1f mmol/L" , level];
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
