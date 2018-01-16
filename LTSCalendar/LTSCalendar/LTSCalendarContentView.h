//
//  LTSCalendarContentView.h
//  LTSCalendar
//
//  Created by 李棠松 on 2018/1/9.
//  Copyright © 2018年 leetangsong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LTSCalendarAppearance.h"
#import "LTSCalendarCollectionViewFlowLayout.h"
#import "LTSCalendarEventSource.h"
@interface LTSCalendarContentView : UIView

@property (nonatomic,strong) LTSCalendarCollectionViewFlowLayout *flowLayout;

@property (nonatomic,strong) UICollectionView *collectionView;
//遮罩
@property (nonatomic,strong)UIView *maskView;
//事件代理
@property (weak, nonatomic) id<LTSCalendarEventSource> eventSource;

@property (nonatomic,strong)NSDate *currentDate;
///滚动到单周需要的offset
@property (nonatomic,assign)CGFloat singleWeekOffsetY;
- (void)setSingleWeek:(BOOL)singleWeek;
///下一页
- (void)getDateDatas;
- (void)loadNextPage;
- (void)loadPreviousPage;
- (void)reloadAppearance;
///更新遮罩镂空的位置 
- (void)setUpVisualRegion;
- (void)goBackToday;
@end
