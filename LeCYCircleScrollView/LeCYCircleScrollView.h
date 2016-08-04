//
//  LeCYCycleScrollView.h
//  LeCYCycleScrollView
//
//  Created by dabao on 16/8/3.
//  Copyright © 2016年 dabao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LeCYCircleScrollView;
@class LeCYCircleViewFlowLayout;

@protocol LeCYCircleScrollViewDataSource <NSObject>
/**
 *  返回要显示的个数
 *
 *  @param circleScrollView
 *
 *  @return number
 */
- (NSInteger)numberOfItemsInCircleScrollView:(nullable LeCYCircleScrollView *)circleScrollView;

/**
 *  返回创建的cell
 *
 *  @param circleScrollView
 *  @param index            位置
 *
 *  @return cell
 */
- (nonnull UICollectionViewCell *)circleScrollView:(nullable LeCYCircleScrollView *)circleScrollView cellForItemAtIndex:(NSInteger)index;
@end

@protocol LeCYCircleScrollViewDelegate <NSObject>
/**
 *  点击cell
 *
 *  @param circleScrollView circleScrollView
 *  @param index            位置
 */
- (void)circleScrollView:(nullable LeCYCircleScrollView *)circleScrollView didSelectItemAtIndex:(NSInteger)index;

/**
 *  当前显示的坐标
 *
 *  @param circleScrollView circleScrollView
 *  @param index            位置
 */
- (void)circleScrollView:(nullable LeCYCircleScrollView *)circleScrollView displayCellAtIndex:(NSInteger)index;
@end

@interface LeCYCircleScrollView : UIView
@property (nonatomic, weak, nullable) id <LeCYCircleScrollViewDelegate> delegate;
@property (nonatomic, weak, nullable) id <LeCYCircleScrollViewDataSource> dataSource;

@property (nonatomic, strong, nullable) LeCYCircleViewFlowLayout *circleFlowLayout;

/** Timer **/
@property (nonatomic, assign) BOOL autoCircleScroll;
@property (nonatomic, assign) NSTimeInterval timeInterval;

/** reload **/
- (void)reloadData;

/**
 *  初始化 (如果选择不赋值layout，要手动赋值circleFlowLayout)
 *
 *  @param frame  传入的frame
 *  @param layout 布局配置
 *
 *  @return LeCYCircleScrollView
 */
- (nonnull instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(nonnull UICollectionViewLayout *)layout;

/**
 *  注册cell
 *
 *  @param cellClass  cellClass description
 *  @param identifier identifier description
 */
- (void)registerClass:(nonnull Class)cellClass identifier:(nonnull NSString *)identifier;

/**
 *  获取队列cell
 *
 *  @param identifier identifier description
 *  @param index      index description
 *
 *  @return cell
 */
- (nonnull __kindof UICollectionViewCell *)dequeueIdentifier:(nonnull NSString *)identifier forIndex:(NSInteger)index;
@end


@interface LeCYCircleViewFlowLayout : UICollectionViewFlowLayout
@property (nonatomic, assign) CGFloat itemScale;
@property (nonatomic, assign) CGFloat alphaScale;
@end

