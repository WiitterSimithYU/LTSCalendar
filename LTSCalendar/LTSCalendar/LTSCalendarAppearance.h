//
//  LTSCalendarAppearance.h
//  LTSCalendar
//
//  Created by leetangsong_macbk on 16/5/24.
//  Copyright © 2016年 leetangsong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LTSCalendarWeekDayFormat) {
    LTSCalendarWeekDayFormatSingle,
    LTSCalendarWeekDayFormatShort,
    LTSCalendarWeekDayFormatFull
};


@interface LTSCalendarAppearance : NSObject


///从星期几开始   8 代表星期天开始 
@property (nonatomic,assign) NSInteger firstWeekday;
///是否显示日历
@property (nonatomic,assign) BOOL isShowLunarCalender;


///每一周视图的高度
@property (nonatomic,assign)CGFloat weekDayHeight;
///每个月显示多少周
@property (nonatomic,assign)NSInteger weeksToDisplay;

@property (nonatomic,assign)BOOL isShowSingleWeek;
///日历背景颜色
@property (nonatomic,strong)UIColor *calendarBgColor;
///星期view背景颜色
@property (nonatomic,strong) UIColor *weekDayBgColor;
///滚动试图背景颜色
@property (nonatomic,strong) UIColor *scrollBgcolor;
///  阳历字体大小
@property (nonatomic,strong)UIFont *dayTextFont;

/// 农历字体大小
@property (nonatomic,strong)UIFont *lunarDayTextFont;


///  阳历文本颜色
@property (nonatomic,strong)UIColor *dayTextColor;
///阳历选择后的文本颜色
@property (strong,nonatomic)UIColor *dayTextColorSelected;
///  农历文本颜色
@property (nonatomic,strong)UIColor *lunarDayTextColor;
/// 农历选择后的文本颜色
@property (nonatomic,strong)UIColor *lunarDayTextColorSelected;
/// 今天文本颜色
@property (strong, nonatomic) UIColor *dayTextColorToday;

@property (nonatomic,strong)UIColor *lineBgColor;

// 其他月份

/// 其他月份阳历字体大小
@property (nonatomic,strong)UIFont *dayTextFontOtherMonth;
///  其他月份农历字体大小
@property (nonatomic,strong)UIFont *lunarDayTextFontOtherMonth;
///  其他月份阳历文本颜色
@property (nonatomic,strong)UIColor *dayTextColorOtherMonth;
///  其他月份农历文本颜色
@property (nonatomic,strong)UIColor *lunarDayTextColorOtherMonth;

/// 选中时日期实心圆的颜色
@property (strong, nonatomic) UIColor *dayCircleColorSelected;
/// 今天实心圆的颜色
@property (nonatomic,strong)  UIColor *dayCircleColorToday;
///  今天外圈圆的颜色
@property (strong, nonatomic) UIColor *dayBorderColorToday;

/// 有事件 点的默认颜色
@property (nonatomic,strong) UIColor *dayDotColor;



///  日期实心圆的大小
@property (assign, nonatomic) CGFloat dayCircleSize;
/// 事件点的大小
@property (assign, nonatomic) CGFloat dayDotSize;


// Weekday
@property (assign, nonatomic) LTSCalendarWeekDayFormat weekDayFormat;
/// 周  标识 颜色
@property (strong, nonatomic) UIColor *weekDayTextColor;
/// 周  标识  字体大小
@property (strong, nonatomic) UIFont *weekDayTextFont;



+ (instancetype)share;
- (NSCalendar *)calendar;
- (NSCalendar *)chineseCalendar;

- (void)setDayDotColorForAll:(UIColor *)dotColor;
- (void)setDayTextColorForAll:(UIColor *)textColor;

@end
