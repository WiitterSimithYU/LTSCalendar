//
//  LTSCalendarCollectionView.m
//  LTSCalendar
//
//  Created by 李棠松 on 2018/1/9.
//  Copyright © 2018年 leetangsong. All rights reserved.
//

#import "LTSCalendarContentView.h"

#import "LTSCalendarCollectionCell.h"
#import "LTSCalendarDayItem.h"
#import "LTSCalendarManager.h"

#define NUMBER_PAGES_LOADED 5
@interface LTSCalendarContentView()<UICollectionViewDataSource,UICollectionViewDelegate>{
    //是否是在点击日期或者滑动改变页数
    BOOL isOwnChangePage;
    //第一次显示周的选中的indexPath
    NSIndexPath *beginWeekIndexPath;
    //是否是上一页
    BOOL isLoadPrevious;
    //是否是下一页
    BOOL isLoadNext;
}

@property (nonatomic,assign)NSInteger currentMonthIndex;
@property (nonatomic,strong)NSArray *daysInMonth;
@property (nonatomic,strong)NSArray *daysInWeeks;
@property (nonatomic,strong)NSIndexPath *currentSelectedIndexPath;
//@property (nonatomic,st)
@end

@implementation LTSCalendarContentView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initUI];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}
- (void)setEventSource:(id<LTSCalendarEventSource>)eventSource{
    _eventSource = eventSource;
    [self updatePageWithNewDate:NO];
    [UIView performWithoutAnimation:^{
        [self.collectionView reloadData];
    }];
}

- (void)initUI
{
    
    
    
    self.flowLayout = [LTSCalendarCollectionViewFlowLayout new];
    self.flowLayout.itemSize = CGSizeMake(self.frame.size.width/7, [LTSCalendarAppearance share].weekDayHeight);
    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.flowLayout.itemCountPerRow = 7;
//    self.flowLayout.rowCount = [LTSCalendarAppearance share].isShowSingleWeek ? 1:[LTSCalendarAppearance share].weeksToDisplay;
    self.flowLayout.rowCount = [LTSCalendarAppearance share].weeksToDisplay;
    self.flowLayout.minimumLineSpacing = 0;
    self.flowLayout.minimumInteritemSpacing = 0;
    self.collectionView = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:self.flowLayout];
    [self addSubview:self.collectionView];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsHorizontalScrollIndicator = false;
    self.collectionView.backgroundColor =  [UIColor clearColor];
    if (@available(iOS 11.0, *)) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self.collectionView registerClass:[LTSCalendarCollectionCell class] forCellWithReuseIdentifier:@"dayCell"];
//    self.collectionView.contentInset = UIEdgeInsetsMake(0, 0,[LTSCalendarAppearance share].isShowSingleWeek ? [LTSCalendarAppearance share].weekDayHeight*([LTSCalendarAppearance share].weeksToDisplay-1) : 0, 0);
    self.backgroundColor = [LTSCalendarAppearance share].calendarBgColor;
    
    ///先初始化数据
    [self getDateDatas];
    
    UIView *maskView = [[UIView alloc] initWithFrame:self.bounds];
    maskView.backgroundColor = [LTSCalendarAppearance share].calendarBgColor;
    maskView.alpha = 0;
    maskView.userInteractionEnabled = false;
    self.maskView = maskView;
    [self addSubview:maskView];
    
    //创建一个CAShapeLayer 图层
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    //添加图层蒙板
    maskView.layer.mask = shapeLayer;
    [self setUpVisualRegion];
}

- (void)setSingleWeek:(BOOL)singleWeek{
    [LTSCalendarAppearance share].isShowSingleWeek = singleWeek;
//    self.flowLayout.rowCount = singleWeek ? 1:[LTSCalendarAppearance share].weeksToDisplay;
//   self.collectionView.contentInset = UIEdgeInsetsMake(0, 0,(singleWeek ? appearance.weekDayHeight*(appearance.weeksToDisplay-1) : 0), 0);
    beginWeekIndexPath = nil;
 
    [self getDateDatas];
    [UIView performWithoutAnimation:^{
        [self.collectionView reloadData];
    }];
    
}

///获取当前选中的frame
- (CGRect)obtainVisualFrame{
    return CGRectMake(0 , ([self weekOfMonthWithDate:self.currentDate]-1)*[LTSCalendarAppearance share].weekDayHeight, CGRectGetWidth(self.frame), [LTSCalendarAppearance share].weekDayHeight);
}
//设置可见的区域
- (void)setUpVisualRegion{
    UIBezierPath *bpath = [UIBezierPath bezierPathWithRoundedRect:self.maskView.bounds cornerRadius:0];
    //贝塞尔曲线 画一个圆形
    
    [bpath appendPath:[[UIBezierPath bezierPathWithRect:[self obtainVisualFrame]] bezierPathByReversingPath]];
    
    ((CAShapeLayer *)self.maskView.layer.mask).path = bpath.CGPath;
}
#pragma mark -- UICollectionViewDataSource --
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return NUMBER_PAGES_LOADED;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
//    if ([LTSCalendarAppearance share].isShowSingleWeek) {
//        return  7;
//    }
    return 7*[LTSCalendarAppearance share].weeksToDisplay;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    LTSCalendarCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"dayCell" forIndexPath:indexPath];
    LTSCalendarDayItem *item = self.daysInMonth[indexPath.section][indexPath.row];
    if ([LTSCalendarAppearance share].isShowSingleWeek) {
        item = self.daysInWeeks[indexPath.section][indexPath.row%7];
    }
    cell.item = item;
    return cell;
}

#pragma mark -- UICollectionViewDelegate --
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    isOwnChangePage = false;
    LTSCalendarCollectionCell *cell = (LTSCalendarCollectionCell*)[collectionView cellForItemAtIndexPath:indexPath];
    cell.isSelected = true;
    LTSCalendarDayItem *itemCurrent;
    LTSCalendarDayItem *itemLast;
    NSArray *dataSource;
    if ([LTSCalendarAppearance share].isShowSingleWeek) {
        dataSource = self.daysInWeeks;
    }else{
        dataSource = self.daysInMonth;
    }

    
    if ( [LTSCalendarAppearance share].isShowSingleWeek) {
        itemLast = dataSource[self.currentSelectedIndexPath.section][self.currentSelectedIndexPath.item%7];
        itemCurrent = dataSource[indexPath.section][indexPath.item%7];
    }else{
        itemCurrent = dataSource[indexPath.section][indexPath.item];
        itemLast = dataSource[self.currentSelectedIndexPath.section][self.currentSelectedIndexPath.item];
    }
    if (itemLast == itemCurrent) {
        return;
    }
    
    itemLast.isSelected = NO;
    
    NSDateComponents *comps = [[LTSCalendarAppearance share].calendar components:NSCalendarUnitMonth | NSCalendarUnitWeekOfMonth | NSCalendarUnitWeekday fromDate:itemCurrent.date];
   
    
    NSInteger touchMonthIndex = [self monthIndexForDate:itemCurrent.date];
    
    NSInteger currentMonth = [self monthIndexForDate:self.currentDate];
    
    if (touchMonthIndex == currentMonth || [LTSCalendarAppearance share].isShowSingleWeek) {
        LTSCalendarCollectionCell *lastCell = (LTSCalendarCollectionCell*)[collectionView cellForItemAtIndexPath:self.currentSelectedIndexPath];
        lastCell.isSelected = false;
    }
    
    NSInteger index = comps.weekday-[LTSCalendarAppearance share].calendar.firstWeekday%7;
    if (index < 0) {
        index += 7;
    }
    
    if ([LTSCalendarAppearance share].isShowSingleWeek) {
        self.currentSelectedIndexPath = indexPath;
        self.currentDate = itemCurrent.date;
    }else{
        self.currentSelectedIndexPath = [NSIndexPath indexPathForItem:(comps.weekOfMonth-1)*7+index inSection:round(NUMBER_PAGES_LOADED / 2)];
        touchMonthIndex = touchMonthIndex % 12;
        
        if(touchMonthIndex == (currentMonth + 1) % 12){
            _currentDate = itemCurrent.date;
             isOwnChangePage = true;
            [self loadNextPage];
        }
        else if(touchMonthIndex == (currentMonth + 12 - 1) % 12){
             _currentDate = itemCurrent.date;
            isOwnChangePage = true;
            [self loadPreviousPage];
        }else{
            self.currentDate = itemCurrent.date;
        }
    }
    
    
}
#pragma mark -- UIScrollView --

//点击滑动
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    
   [self updatePageWithNewDate:!isOwnChangePage];
    [UIView performWithoutAnimation:^{
        [self.collectionView reloadData];
    }];

    if (self.eventSource && [self.eventSource respondsToSelector:@selector(calendarDidLoadPageCurrentDate:)]) {
        [self.eventSource calendarDidLoadPageCurrentDate:self.currentDate];
    }
    isOwnChangePage = false;
    
}

//手指滑动
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    isOwnChangePage = false;
    //如通过手指滑动更换月份  则默认选中 与当前日期相等的 日子
    //如果是按月份显示
    
    //如果是按周显示
    CGFloat pageWidth = CGRectGetWidth(self.frame);
    CGFloat fractionalPage = self.collectionView.contentOffset.x / pageWidth;
    
    int currentPage = roundf(fractionalPage);
    
    if (currentPage == round(NUMBER_PAGES_LOADED / 2)){
        return;
    };
    [self updatePageWithNewDate:YES];
    [UIView performWithoutAnimation:^{
        [self.collectionView reloadData];
    }];
    if (self.eventSource && [self.eventSource respondsToSelector:@selector(calendarDidLoadPageCurrentDate:)]) {
        [self.eventSource calendarDidLoadPageCurrentDate:self.currentDate];
    }
    
}



#pragma mark -- Function --

- (void)reloadAppearance{
    self.backgroundColor = [LTSCalendarAppearance share].calendarBgColor;
    self.maskView.backgroundColor = self.backgroundColor;
    [self getDateDatas];
    [UIView performWithoutAnimation:^{
        [self.collectionView reloadData];
    }];
}

- (void)getDateDatas{
    NSCalendar *calendar = [LTSCalendarAppearance share].calendar;
    
   
    if (self.currentDate == nil) {
        self.currentDate = [NSDate date];
    }
    
    if ([LTSCalendarAppearance share].isShowSingleWeek) {
        NSMutableArray *daysInWeeks = [@[] mutableCopy];
        //获取前两周和后两周的日期
        for(int i = 0; i < NUMBER_PAGES_LOADED; i++){
            
            NSDateComponents *dayComponent = [NSDateComponents new];
            
            //            NSDate *weekBegin =
            dayComponent.weekOfYear = i - NUMBER_PAGES_LOADED / 2;
            //获取前两周和后两周的日期
            NSDate *weakDate = [calendar dateByAddingComponents:dayComponent toDate:[self beginningOfWeek:self.currentDate] options:0];
            
            self.currentMonthIndex = [self monthIndexForDate:self.currentDate];
            
            
            [daysInWeeks addObject:[self getDaysOfWeek:weakDate]];
            
        }
        self.daysInWeeks = daysInWeeks;
    }else{
        NSMutableArray *daysInMonths = [@[] mutableCopy];
        for(int i = 0; i < NUMBER_PAGES_LOADED; i++){
            
            NSDateComponents *dayComponent = [NSDateComponents new];
            
            
            dayComponent.month = i - NUMBER_PAGES_LOADED / 2;
            //当前日期前两个月  与  后两个月
            NSDate *monthDate = [calendar dateByAddingComponents:dayComponent toDate:self.currentDate options:0];
            
            monthDate = [self beginningOfMonth:monthDate];
            [daysInMonths addObject:[self getDaysOfMonth:monthDate]];
            
        }
        
        self.daysInMonth = daysInMonths;
        
    }
    
    
    [self repositionViews];
}
///下一页
- (void)loadNextPage{
    isLoadPrevious = false;
    isLoadNext = true;
    [self.collectionView setContentOffset:CGPointMake(self.frame.size.width*(round(NUMBER_PAGES_LOADED/2)+1), 0) animated:YES];
    
}
///上一页
- (void)loadPreviousPage{
    isLoadPrevious = true;
    isLoadNext = false;
    [self.collectionView setContentOffset:CGPointMake(self.frame.size.width*(round(NUMBER_PAGES_LOADED/2)-1), 0) animated:YES];
    
}

- (void)updatePageWithNewDate:(BOOL)isNew
{
    
    //如果是显示周 默认 选中该周第一天
    //如果是月 默认 选中已选天数的日 若没有该日 则选中该月最后一天
    NSDate *currentDate = [self getNewCurrentDate];
    if (!currentDate) {
        currentDate = self.currentDate;
    }
    
    //获取该周第一天
    if ([LTSCalendarAppearance share].isShowSingleWeek) {
         currentDate = [self beginningOfWeek:currentDate];
    }
    if (!isNew) {
        currentDate = self.currentDate;
    }
    
    self.currentDate = currentDate;
    [self getDateDatas];
}


///滚动到中间的位置，停止滚动后 始终滚动是在中间
- (void)repositionViews{
    [self.collectionView setContentOffset:CGPointMake(self.frame.size.width*round(NUMBER_PAGES_LOADED/2), 0)];
}


- (NSDate *)getNewCurrentDate{
    CGFloat pageWidth = CGRectGetWidth(self.frame);
    CGFloat fractionalPage = self.collectionView.contentOffset.x / pageWidth;
    
    int currentPage = roundf(fractionalPage);
    
    if (currentPage == round(NUMBER_PAGES_LOADED / 2) && [LTSCalendarAppearance share].isShowSingleWeek){
        self.collectionView.scrollEnabled = YES;
        return nil;
    }
    
    NSCalendar *calendar = [LTSCalendarAppearance share].calendar;
    NSDateComponents *dayComponent = [NSDateComponents new];
    NSDate *currentDate;
    if ([LTSCalendarAppearance share].isShowSingleWeek) {
        dayComponent.weekOfYear = currentPage - (NUMBER_PAGES_LOADED / 2);
        currentDate = [calendar dateByAddingComponents:dayComponent toDate:[self beginningOfWeek:self.currentDate] options:0];
    }else{
      
        dayComponent.day = 0;
        dayComponent.month = currentPage - (NUMBER_PAGES_LOADED / 2);
        currentDate = [calendar dateByAddingComponents:dayComponent toDate:self.currentDate options:0];
    }
  
    return currentDate;
}

- (CGFloat)singleWeekOffsetY{
    return  self.currentSelectedIndexPath.row/7*[LTSCalendarAppearance share].weekDayHeight;
}
- (void)setCurrentDate:(NSDate *)currentDate{
    _currentDate = currentDate;
    if (self.eventSource && [self.eventSource respondsToSelector:@selector(calendarDidSelectedDate:)]) {
        [self.eventSource calendarDidSelectedDate:self.currentDate];
    }
}

/**
 *  返回该日期月数第一周开始的第一天
 *
 *  @param date  date
 *
 *  @return date
 */
- (NSDate *)beginningOfMonth:(NSDate *)date{
    NSCalendar *calendar = [LTSCalendarAppearance share].calendar;
    
    NSDateComponents *componentsCurrentDate =[calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday|NSCalendarUnitWeekOfMonth fromDate:date];
    
    
    NSDateComponents *componentsNewDate = [NSDateComponents new];
    
    componentsNewDate.year = componentsCurrentDate.year;
    componentsNewDate.month = componentsCurrentDate.month;
    componentsNewDate.weekOfMonth = 1;
    componentsNewDate.weekday = calendar.firstWeekday;
    
    return [calendar dateFromComponents:componentsNewDate];
    
}

///获取日期在当月的周数
- (NSInteger)weekOfMonthWithDate:(NSDate *)date{
    NSCalendar *calendar = [LTSCalendarAppearance share].calendar;
    NSDateComponents *components =[calendar components:NSCalendarUnitWeekOfMonth fromDate:date];
    return components.weekOfMonth;
}
/**
 *  返回该日期周开始的第一天
 *
 *  @param date  date
 *
 *  @return date
 */
- (NSDate *)beginningOfWeek:(NSDate *)date{
    NSCalendar *calendar = [LTSCalendarAppearance share].calendar;
    
    NSDateComponents *componentsCurrentDate =[calendar components:NSCalendarUnitDay | NSCalendarUnitWeekday fromDate:date];
    
    NSInteger index = componentsCurrentDate.weekday-[LTSCalendarAppearance share].calendar.firstWeekday%7;
    if (index < 0) {
        index += 7;
    }
    
    NSTimeInterval first = date.timeIntervalSince1970-index*24*3600;
    
    return [NSDate dateWithTimeIntervalSince1970:first];
    
}

- (NSArray *)getDaysOfWeek:(NSDate *)date
{
    NSDate *currentDate = date;
    
    NSCalendar *calendar = [LTSCalendarAppearance share].calendar;
    
    //每一周的 date
    NSMutableArray *daysOfweek = [@[] mutableCopy];
    
    for (NSInteger i=0; i<7; i++) {
        NSDateComponents *comps = [calendar components:NSCalendarUnitMonth | NSCalendarUnitWeekOfMonth fromDate:currentDate];
        NSInteger monthIndex = comps.month;
        
        LTSCalendarDayItem *item = [LTSCalendarDayItem new];
        item.isOtherMonth = monthIndex != self.currentMonthIndex;
        item.date = currentDate;
        if ([self isEqual:currentDate other:self.currentDate]) {
            item.isSelected = YES;
            self.currentSelectedIndexPath = [NSIndexPath indexPathForItem:(comps.weekOfMonth-1)*7+i inSection:round(NUMBER_PAGES_LOADED / 2)];
            
            if ([LTSCalendarAppearance share].isShowSingleWeek) {
                if (beginWeekIndexPath) {
                    self.currentSelectedIndexPath = [NSIndexPath indexPathForRow:beginWeekIndexPath.row/7*7 inSection:round(NUMBER_PAGES_LOADED / 2)];
                }
                if (beginWeekIndexPath == nil) {
                    beginWeekIndexPath = self.currentSelectedIndexPath;
                }
            }
           
            
        }
        
        item.eventDotColor = [LTSCalendarAppearance share].dayDotColor;
        if (self.eventSource && [self.eventSource respondsToSelector:@selector(calendarHaveEventWithDate:)]) {
            item.showEventDot = [self.eventSource calendarHaveEventWithDate:currentDate];
        }
        if (self.eventSource && [self.eventSource respondsToSelector:@selector(calendarHaveEventDotColorWithDate:)]) {
            item.eventDotColor = [self.eventSource calendarHaveEventDotColorWithDate:currentDate];
        }
        NSDateComponents *dayComponent = [NSDateComponents new];
        dayComponent.day = 1;
        [daysOfweek addObject:item];
        currentDate = [calendar dateByAddingComponents:dayComponent toDate:currentDate options:0];
    }
    return  daysOfweek;
    
}

- (NSArray*)getDaysOfMonth:(NSDate *)date
{
    NSDate *currentDate = date;
    
    NSCalendar *calendar = [LTSCalendarAppearance share].calendar;
    
    //每一月的 date
    NSMutableArray *daysOfMonth = [@[] mutableCopy];
    {
        NSDateComponents *comps = [calendar components:NSCalendarUnitMonth|NSCalendarUnitDay fromDate:currentDate];
        
        self.currentMonthIndex = comps.month;
        
        //每月开始的第一天不是 1   则是上一个月的
        if(comps.day > 1){
            self.currentMonthIndex = (self.currentMonthIndex % 12) + 1;
            
        }
    }
    
    for (NSInteger i = 0; i<[LTSCalendarAppearance share].weeksToDisplay; i++) {
        NSDateComponents *dayComponent = [NSDateComponents new];
        dayComponent.day = 7;
        NSArray *array = [self getDaysOfWeek:currentDate];
        
        [daysOfMonth addObjectsFromArray:array];
        currentDate = [calendar dateByAddingComponents:dayComponent toDate:currentDate options:0];
    }

    return daysOfMonth;
}
- (NSInteger)monthIndexForDate:(NSDate *)date
{
    NSCalendar *calendar = [LTSCalendarAppearance share].calendar;
    NSDateComponents *comps = [calendar components:NSCalendarUnitMonth fromDate:date];
    return comps.month;
}

///比较日期是否相等
- (BOOL)isEqual:(NSDate *)date1 other:(NSDate *)date2{
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.timeZone = [LTSCalendarAppearance share].calendar.timeZone;
    dateFormatter.dateFormat = @"yyyy.MM.dd";
    
    return [[dateFormatter stringFromDate:date1] isEqualToString:[dateFormatter stringFromDate:date2]];
    
}

@end
