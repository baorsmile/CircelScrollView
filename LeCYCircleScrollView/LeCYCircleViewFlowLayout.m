//
//  LeCYFocusViewFlowLayout.m
//  LeDimension
//
//  Created by dabao on 16/8/2.
//  Copyright © 2016年 LeEco. All rights reserved.
//

#import "LeCYCircleViewFlowLayout.h"

@implementation LeCYCircleViewFlowLayout
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.itemScale = 1.0;
        self.alphaScale = 1.0;
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
        CGFloat scale = self.itemScale + (1 - self.itemScale) * (1 - distance /(self.itemSize.width + self.minimumLineSpacing));
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
