//
//  LeCYCycleScrollView.m
//  LeCYCycleScrollView
//
//  Created by dabao on 16/8/3.
//  Copyright © 2016年 dabao. All rights reserved.
//

#import "LeCYCircleScrollView.h"

static inline NSIndexPath *CircleIndexPath(NSInteger index) {
    return [NSIndexPath indexPathForItem:index inSection:0];
}

@interface LeCYCircleScrollView () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) LeCYCircleViewFlowLayout *flowLayout;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger currentNumber;          // 处理过的个数
@property (nonatomic, assign) NSInteger originalNumber;         // 原始数据个数
@property (nonatomic, getter=isOnlyOneItem) BOOL onlyOneItem;   // 是否只有一个数据，单独处理
@end

@implementation LeCYCircleScrollView
- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(nonnull UICollectionViewLayout *)layout
{
    self = [super initWithFrame:frame];
    if (self) {
        self.flowLayout = (LeCYCircleViewFlowLayout *)layout;
        [self addSubview:self.collectionView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [self initWithFrame:frame collectionViewLayout:self.flowLayout];
    if (self) {}
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

- (BOOL)isOnlyOneItem
{
    if (self.currentNumber <= 1) {
        return YES;
    }
    return NO;
}

#pragma mark - Set
- (void)setAutoCircleScroll:(BOOL)autoCircleScroll
{
    _autoCircleScroll = autoCircleScroll;
    [self setUpTimer];
}

- (void)setTimeInterval:(NSTimeInterval)timeInterval {
    _timeInterval = timeInterval;
    [self setUpTimer];
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
    if (self.onlyOneItem) {
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
    NSInteger pageIndex = (self.collectionView.contentOffset.x + self.flowLayout.itemSize.width + self.flowLayout.minimumLineSpacing) / (self.flowLayout.itemSize.width + self.flowLayout.minimumLineSpacing);
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
    CGFloat targetOffset  = currentOffset + self.flowLayout.itemSize.width + self.flowLayout.minimumLineSpacing;
    
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
        CGFloat kCellSpaceHeader = (self.collectionView.bounds.size.width - self.flowLayout.itemSize.width - self.flowLayout.minimumLineSpacing* 2) / 2;
        CGFloat kCellContentSizeWidth = self.flowLayout.minimumLineSpacing + self.flowLayout.itemSize.width;
        if (scrollView.contentOffset.x < self.flowLayout.itemSize.width - kCellSpaceHeader) {
            [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x + kCellContentSizeWidth * (self.currentNumber - 4), 0)];
        } else if (scrollView.contentOffset.x > (kCellContentSizeWidth * (self.currentNumber - 2)) + kCellSpaceHeader) {
            [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x - kCellContentSizeWidth * (self.currentNumber - 4), 0)];
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.onlyOneItem) {
        [self tearDownTimer];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.onlyOneItem) {
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


@implementation LeCYCircleViewFlowLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.itemScale = 1.0;
        self.alphaScale = 1.0;
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return self;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *attributes = [super layoutAttributesForElementsInRect:rect];
    
    if (self.itemScale == 1.0 && self.alphaScale == 1.0) {
        return attributes;
    }
    
    CGFloat centerX = self.collectionView.contentOffset.x + self.collectionView.bounds.size.width * 0.5;
    for (UICollectionViewLayoutAttributes *layoutAttributes in attributes) {
        CGFloat distance = ABS(layoutAttributes.center.x - centerX);
        CGFloat scale = self.itemScale + (1 - self.itemScale) * (1 - distance / (self.itemSize.width + self.minimumLineSpacing));
        layoutAttributes.transform = CGAffineTransformMakeScale(scale, scale);
    }
    
    if (attributes.count == 1) {
        // 只存在一个时候居中显示
        UICollectionViewLayoutAttributes *layoutAttributes = attributes.firstObject;
        CGPoint center = layoutAttributes.center;
        center.x = self.collectionView.bounds.size.width * 0.5;
        layoutAttributes.center = center;
    }
    return attributes;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    CGFloat proposedContentOffsetCenterX = proposedContentOffset.x + CGRectGetWidth(self.collectionView.bounds) * 0.5;
    
    NSArray *layoutAttributesForElements = [self layoutAttributesForElementsInRect:self.collectionView.bounds];
    
    UICollectionViewLayoutAttributes *layoutAttributes = layoutAttributesForElements.firstObject;
    
    for (UICollectionViewLayoutAttributes *layoutAttributesForElement in layoutAttributesForElements) {
        if (layoutAttributesForElement.representedElementCategory != UICollectionElementCategoryCell) {
            continue;
        }
        
        CGFloat distance1 = layoutAttributesForElement.center.x - proposedContentOffsetCenterX;
        CGFloat distance2 = layoutAttributes.center.x - proposedContentOffsetCenterX;
        
        if (fabs(distance1) < fabs(distance2)) {
            layoutAttributes = layoutAttributesForElement;
        }
    }
    
    if (layoutAttributes != nil) {
        return CGPointMake(layoutAttributes.center.x - CGRectGetWidth(self.collectionView.bounds) * 0.5, proposedContentOffset.y);
    }
    
    return [super targetContentOffsetForProposedContentOffset:proposedContentOffset
                                        withScrollingVelocity:velocity];
}


@end
