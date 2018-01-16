//
//  LTSCalendarViewController.m
//  LTSCalendar
//
//  Created by 李棠松 on 2018/1/12.
//  Copyright © 2018年 leetangsong. All rights reserved.
//

#import "LTSCalendarViewController.h"
#import "LTSCalendarManager.h"

@interface LTSCalendarViewController ()<LTSCalendarEventSource>
{
    NSMutableDictionary *eventsByDate;
}

@property (nonatomic,strong)LTSCalendarManager *manager;

@end

@implementation LTSCalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.manager = [LTSCalendarManager new];
    self.manager.eventSource = self;
    self.manager.weekDayView = [[LTSCalendarWeekDayView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 30)];
    [self.view addSubview:self.manager.weekDayView];
    
    self.manager.calenderScrollView = [[LTSCalendarScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.manager.weekDayView.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-CGRectGetMaxY(self.manager.weekDayView.frame))];
    [self.view addSubview:self.manager.calenderScrollView];
    [self createRandomEvents];
   self.automaticallyAdjustsScrollViewInsets = false;
    
    
    // Do any additional setup after loading the view.
}


- (void)calendarDidLoadPageCurrentDate:(NSDate *)date {
     NSLog([NSString stringWithFormat:@"%@",date]);
}

- (void)calendarDidSelectedDate:(NSDate *)date {
    NSLog([NSString stringWithFormat:@"%@",date]);
}

- (BOOL)calendarHaveEventWithDate:(NSDate *)date {
    
    NSString *key = [[self dateFormatter] stringFromDate:date];
    
    if(eventsByDate[key] && [eventsByDate[key] count] > 0){
        return YES;
    }
    return NO;
}

- (void)createRandomEvents
{
    eventsByDate = [NSMutableDictionary new];
    
    for(int i = 0; i < 30; ++i){
        // Generate 30 random dates between now and 60 days later
        NSDate *randomDate = [NSDate dateWithTimeInterval:(rand() % (3600 * 24 * 60)) sinceDate:[NSDate date]];
        
        // Use the date as key for eventsByDate
        NSString *key = [[self dateFormatter] stringFromDate:randomDate];
        
        if(!eventsByDate[key]){
            eventsByDate[key] = [NSMutableArray new];
        }
        
        [eventsByDate[key] addObject:randomDate];
    }
    [self.manager reloadAppearanceAndData];
}
- (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *dateFormatter;
    if(!dateFormatter){
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"yyyy.MM.dd";
    }
    
    return dateFormatter;
}




@end
