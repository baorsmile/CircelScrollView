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
- (nonnull UICollectionViewCell *)circleScrollView:(nullable LeCYCircleScrollView *)circleScrollView cellForItemAtIndex:(NSInteger)index;
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

- (void)reloadData;

- (nonnull instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(nonnull UICollectionViewLayout *)layout;

- (void)registerClass:(nonnull Class)cellClass identifier:(nonnull NSString *)identifier;
- (nonnull __kindof UICollectionViewCell *)dequeueIdentifier:(nonnull NSString *)identifier forIndex:(NSInteger)index;
@end


@interface LeCYCircleViewFlowLayout : UICollectionViewFlowLayout
@property (nonatomic, assign) CGFloat itemScale;
@property (nonatomic, assign) CGFloat alphaScale;
@end

