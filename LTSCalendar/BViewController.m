//
//  BViewController.m
//  LTSCalendar
//
//  Created by 李棠松 on 2018/1/9.
//  Copyright © 2018年 leetangsong. All rights reserved.
//

#import "BViewController.h"
#import "LTSCalendarContentView.h"
#import "LTSCalendarWeekDayView.h"
@interface BViewController ()
@property (nonatomic,strong)LTSCalendarContentView *calendarView;
@end

@implementation BViewController
- (IBAction)click:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self.calendarView setSingleWeek:sender.isSelected];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    LTSCalendarWeekDayView *dayView = [[LTSCalendarWeekDayView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 30)];
    [self.view addSubview:dayView];

    LTSCalendarContentView *view = [[LTSCalendarContentView alloc]initWithFrame:CGRectMake(0, 64+30, 375, [LTSCalendarAppearance share].weekDayHeight*[LTSCalendarAppearance share].weeksToDisplay)];
    view.currentDate = [NSDate date];
    self.automaticallyAdjustsScrollViewInsets = false;
    [self.view addSubview:view];
    self.calendarView = view;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
