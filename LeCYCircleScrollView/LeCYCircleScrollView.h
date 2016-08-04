//
//  LeCYCycleScrollView.h
//  LeCYCycleScrollView
//
//  Created by dabao on 16/8/3.
//  Copyright © 2016年 dabao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LeCYCircleScrollView;

@protocol LeCYCircleScrollViewDataSource <NSObject>
- (NSInteger)numberOfItemsInCircleScrollView:(nullable LeCYCircleScrollView *)circleScrollView;
- (nullable UICollectionViewCell *)circleScrollView:(nullable LeCYCircleScrollView *)circleScrollView cellForItemAtIndex:(NSInteger)index;
@end

@protocol LeCYCircleScrollViewDelegate <NSObject>
- (void)circleScrollView:(nullable LeCYCircleScrollView *)circleScrollView didSelectItemAtIndex:(NSInteger)index;
- (void)circleScrollView:(nullable LeCYCircleScrollView *)circleScrollView displayCellAtIndex:(NSInteger)index;
@end

@interface LeCYCircleScrollView : UIView
@property (nonatomic, weak, nullable) id <LeCYCircleScrollViewDelegate> delegate;
@property (nonatomic, weak, nullable) id <LeCYCircleScrollViewDataSource> dataSource;

/** Timer **/
@property (nonatomic, assign) BOOL autoCircleScroll;
@property (nonatomic, assign) NSTimeInterval timeInterval;

/** Layout **/
@property (nonatomic, assign) CGSize itemSize;
@property (nonatomic, assign) CGFloat itemSpacing;
@property (nonatomic, assign) CGFloat itemScale;
@property (nonatomic, assign) CGFloat alphaScale;

- (void)reloadData;

- (void)registerClass:(nullable Class)cellClass identifier:(nullable NSString *)identifier;
- (nullable __kindof UICollectionViewCell *)dequeueIdentifier:(nullable NSString *)identifier forIndex:(NSInteger)index;
@end


@interface LeCYCircleViewFlowLayout : UICollectionViewFlowLayout
@property (nonatomic, assign) CGFloat itemScale;
@property (nonatomic, assign) CGFloat alphaScale;
@end

