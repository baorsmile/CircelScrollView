//
//  LeCYCycleScrollView.m
//  LeCYCycleScrollView
//
//  Created by dabao on 16/8/3.
//  Copyright © 2016年 dabao. All rights reserved.
//

#import "LeCYCircleScrollView.h"
#import "LeCYCircleViewFlowLayout.h"

static inline NSIndexPath *CircleIndexPath(NSInteger index) {
    return [NSIndexPath indexPathForItem:index inSection:0];
}

@interface LeCYCircleScrollView () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) LeCYCircleViewFlowLayout *flowLayout;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger currentNumber;      // 处理过的个数
@property (nonatomic, assign) NSInteger originalNumber;     // 原始数据个数
@end

@implementation LeCYCircleScrollView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.collectionView];
    }
    return self;
}

#pragma mark - Get
- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:self.flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    }
    return _collectionView;
}

- (LeCYCircleViewFlowLayout *)flowLayout
{
    if (!_flowLayout) {
        _flowLayout = [[LeCYCircleViewFlowLayout alloc] init];
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return _flowLayout;
}

- (NSInteger)currentNumber
{
    if (_currentNumber == 0) {
        _currentNumber = self.originalNumber;
        if (_currentNumber > 1) {
            _currentNumber += 4;
        }
    }
    return _currentNumber;
}

- (NSInteger)originalNumber
{
    if (_originalNumber == 0) {
        _originalNumber = [self.dataSource numberOfItemsInCircleScrollView:self];
    }
    return _originalNumber;
}

#pragma mark - Set
- (void)setItemSize:(CGSize)itemSize {
    _itemSize = itemSize;
    self.flowLayout.itemSize = itemSize;
}

- (void)setItemSpacing:(CGFloat)itemSpacing {
    _itemSpacing = itemSpacing;
    self.flowLayout.minimumLineSpacing = itemSpacing;
}

- (void)setAutoCircleScroll:(BOOL)autoCircleScroll
{
    _autoCircleScroll = autoCircleScroll;
    [self setUpTimer];
}

- (void)setTimeInterval:(NSTimeInterval)timeInterval {
    _timeInterval = timeInterval;
    [self setUpTimer];
}

- (void)setItemScale:(CGFloat)itemScale
{
    _itemScale = itemScale;
    self.flowLayout.itemScale = itemScale;

}

- (void)setAlphaScale:(CGFloat)alphaScale
{
    _alphaScale = alphaScale;
    self.flowLayout.alphaScale = alphaScale;
}


#pragma mark - Evnet
- (void)reloadData
{
    __weak typeof(self) weakSelf = self;
    [self.collectionView performBatchUpdates:^{
        [weakSelf.collectionView reloadData];
    } completion:^(BOOL finished) {
        if (weakSelf.currentNumber > 1) {
            if (CGPointEqualToPoint(weakSelf.collectionView.contentOffset, CGPointZero)) {
                [weakSelf.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]
                                                atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                                        animated:NO];
                [self reportStatus];
            }
        }
        
        [weakSelf setUpTimer];
    }];
}

- (void)registerClass:(Class)cellClass identifier:(NSString *)identifier
{
    [self.collectionView registerClass:cellClass forCellWithReuseIdentifier:identifier];
}

- (__kindof UICollectionViewCell *)dequeueIdentifier:(NSString *)identifier forIndex:(NSInteger)index
{
    return [self.collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:CircleIndexPath(index)];
}

- (NSIndexPath *)cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.currentNumber <= 1) {
        return indexPath;
    }
    
    if (indexPath.item == 1) {
        return [NSIndexPath indexPathForItem:self.originalNumber - 1 inSection:indexPath.section];
    } else if (indexPath.item == 0) {
        return [NSIndexPath indexPathForItem:self.originalNumber - 2 inSection:indexPath.section];
    } else if (indexPath.item == self.currentNumber - 1) {
        return [NSIndexPath indexPathForItem:1 inSection:indexPath.section];
    } else if (indexPath.item == self.currentNumber - 2) {
        return [NSIndexPath indexPathForItem:0 inSection:indexPath.section];
    } else {
        return [NSIndexPath indexPathForItem:indexPath.item - 2 inSection:indexPath.section];
    }
}

- (void)reportStatus
{
    NSInteger pageIndex = (self.collectionView.contentOffset.x + self.itemSize.width + self.itemSpacing) / (self.itemSize.width + self.itemSpacing);
    NSIndexPath *indexPath = [self cellForItemAtIndexPath:CircleIndexPath(pageIndex)];
    if (self.delegate && [self.delegate respondsToSelector:@selector(circleScrollView:displayCellAtIndex:)]) {
        [self.delegate circleScrollView:self displayCellAtIndex:indexPath.item];
    }
}


#pragma mark - Timer
- (void)setUpTimer
{
    [self tearDownTimer];
    
    if (!self.autoCircleScroll || self.currentNumber <= 1) return;
    
    self.timer = [NSTimer timerWithTimeInterval:self.timeInterval
                                         target:self
                                       selector:@selector(timerFire:)
                                       userInfo:nil
                                        repeats:YES];
    
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)tearDownTimer {
    [self.timer invalidate];
}

- (void)timerFire:(NSTimer *)timer
{
    CGFloat currentOffset = self.collectionView.contentOffset.x;
    CGFloat targetOffset  = currentOffset + self.itemSize.width + self.itemSpacing;
    
    [self.collectionView setContentOffset:CGPointMake(targetOffset, self.collectionView.contentOffset.y) animated:YES];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.currentNumber;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.dataSource circleScrollView:self cellForItemAtIndex:[self cellForItemAtIndexPath:indexPath].item];
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(circleScrollView:didSelectItemAtIndex:)]) {
        [self.delegate circleScrollView:self didSelectItemAtIndex:[self cellForItemAtIndexPath:indexPath].item];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.currentNumber > 1) {
        CGFloat kCellSpaceHeader = (self.collectionView.bounds.size.width - self.itemSize.width - self.itemSpacing * 2) / 2;
        CGFloat kCellContentSizeWidth = self.itemSpacing + self.itemSize.width;
        if (scrollView.contentOffset.x < self.itemSize.width - kCellSpaceHeader) {
            [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x + kCellContentSizeWidth * (self.currentNumber - 4), 0)];
        } else if (scrollView.contentOffset.x > (kCellContentSizeWidth * (self.currentNumber - 2)) + kCellSpaceHeader) {
            [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x - kCellContentSizeWidth * (self.currentNumber - 4), 0)];
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.currentNumber > 1) {
        [self tearDownTimer];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.currentNumber > 1) {
        [self setUpTimer];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self reportStatus];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self reportStatus];
}


@end
