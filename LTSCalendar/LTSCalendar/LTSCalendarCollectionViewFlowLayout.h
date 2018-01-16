//
//  LTSCalendarCollectionViewFlowLauout.h
//  LTSCalendar
//
//  Created by 李棠松 on 2018/1/9.
//  Copyright © 2018年 leetangsong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LTSCalendarCollectionViewFlowLayout : UICollectionViewFlowLayout
@property (nonatomic,assign) NSUInteger itemCountPerRow;

//    一页显示多少行
@property (nonatomic,assign) NSUInteger rowCount;
@end
