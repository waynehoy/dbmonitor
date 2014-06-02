//
//  HistoryViewController.h
//  DBMonitor
//
//  Created by Lorenzo Bertucci on 2014-06-02.
//  Copyright (c) 2014 Wayne Hoy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryViewController : UIViewController

@property (nonatomic, strong) IBOutlet UILabel* date1;
@property (nonatomic, strong) IBOutlet UILabel* date2;
@property (nonatomic, strong) IBOutlet UILabel* date3;

@property (nonatomic, strong) IBOutlet UILabel* dataPt1;
@property (nonatomic, strong) IBOutlet UILabel* dataPt2;
@property (nonatomic, strong) IBOutlet UILabel* dataPt3;

@property (nonatomic, strong) IBOutlet UILabel* lastDataPt;

@end
