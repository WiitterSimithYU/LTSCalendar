//
//  LTSCalendarCollectionCell.h
//  LTSCalendar
//
//  Created by 李棠松 on 2018/1/9.
//  Copyright © 2018年 leetangsong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LTSCalendarDayItem.h"
@interface LTSCalendarCollectionCell : UICollectionViewCell
@property (nonatomic,strong)LTSCalendarDayItem *item;
@property (nonatomic,assign)BOOL isSelected;
@end
