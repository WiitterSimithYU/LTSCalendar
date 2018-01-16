//
//  ViewController.m
//  LTSCalendar
//
//  Created by 李棠松 on 2016/12/26.
//  Copyright © 2016年 leetangsong. All rights reserved.
//

#import "ViewController.h"
#import "LTSCalendarManager.h"


#define RGBColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
#define RandColor RGBColor(arc4random_uniform(255), arc4random_uniform(255), arc4random_uniform(255))
@interface ViewController ()<LTSCalendarEventSource>{
    NSMutableDictionary *eventsByDate;
}
@property (weak, nonatomic) IBOutlet UILabel *label;


@property (nonatomic,strong)LTSCalendarManager *manager;


@end

@implementation ViewController
- (IBAction)changeColor:(id)sender {
     [LTSCalendarAppearance share].calendarBgColor = RandColor;
     [LTSCalendarAppearance share].weekDayBgColor = RandColor;
     [LTSCalendarAppearance share].dayCircleColorSelected = RandColor;
     [LTSCalendarAppearance share].dayCircleColorToday = RandColor;
     [LTSCalendarAppearance share].dayBorderColorToday = RandColor;
     [LTSCalendarAppearance share].dayDotColor = RandColor;
     [LTSCalendarAppearance share].dayDotColor = RandColor;
    [LTSCalendarAppearance share].lunarDayTextColor = RandColor;
    
    [self.manager reloadAppearanceAndData];
    
    
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self lts_InitUI];
    
}
- (IBAction)goBackToday:(id)sender {
    [self.manager goBackToday];
}


- (IBAction)allweek:(id)sender {
    [self.manager showAllWeek];
}
- (IBAction)singleweek:(id)sender {
    [self.manager showSingleWeek];
}
- (void)lts_InitUI{

    
    self.manager = [LTSCalendarManager new];
    self.manager.eventSource = self;
    self.manager.weekDayView = [[LTSCalendarWeekDayView alloc]initWithFrame:CGRectMake(0, 200, self.view.frame.size.width, 30)];
    [self.view addSubview:self.manager.weekDayView];
    
    self.manager.calenderScrollView = [[LTSCalendarScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.manager.weekDayView.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-CGRectGetMaxY(self.manager.weekDayView.frame))];
    [self.view addSubview:self.manager.calenderScrollView];
    [self createRandomEvents];
    self.automaticallyAdjustsScrollViewInsets = false;
    
}

// 该日期是否有事件
- (BOOL)calendarHaveEventWithDate:(NSDate *)date {
    
    NSString *key = [[self dateFormatter] stringFromDate:date];
    
    if(eventsByDate[key] && [eventsByDate[key] count] > 0){
        return YES;
    }
    return NO;
}
//当前 选中的日期  执行的方法
- (void)calendarDidSelectedDate:(NSDate *)date {
    
    NSString *key = [[self dateFormatter] stringFromDate:date];
    self.label.text =  key;
    NSArray *events = eventsByDate[key];
   self.title = key;
    NSLog(@"%@",date);
    if (events.count>0) {
        
        //该日期有事件    tableView 加载数据
    }
}

- (IBAction)isShowLunar:(id)sender {
    [LTSCalendarAppearance share].isShowLunarCalender = ![LTSCalendarAppearance share].isShowLunarCalender;
   //重新加载外观
    [self.manager reloadAppearanceAndData];

}
- (IBAction)nextMonth:(id)sender {
    [self.manager loadNextPage];
}

- (IBAction)previousMonth:(id)sender {
    [self.manager loadPreviousPage];
}
- (IBAction)monday:(id)sender {
    [LTSCalendarAppearance share].firstWeekday = 2;
    [self.manager reloadAppearanceAndData];
}
- (IBAction)sunday:(id)sender {
    [LTSCalendarAppearance share].firstWeekday = 1;

    [self.manager reloadAppearanceAndData];
}
- (IBAction)full:(id)sender {
    [LTSCalendarAppearance share].weekDayFormat = LTSCalendarWeekDayFormatFull;
    [self.manager.weekDayView reloadAppearance];
}
- (IBAction)fullShort:(id)sender {
    [LTSCalendarAppearance share].weekDayFormat = LTSCalendarWeekDayFormatShort;
    [self.manager.weekDayView reloadAppearance];
}
- (IBAction)single:(id)sender {
    [LTSCalendarAppearance share].weekDayFormat = LTSCalendarWeekDayFormatSingle;
    [self.manager.weekDayView reloadAppearance];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
