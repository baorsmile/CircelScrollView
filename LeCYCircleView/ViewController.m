//
//  ViewController.m
//  LeCYCircleView
//
//  Created by dabao on 16/8/3.
//  Copyright © 2016年 dabao. All rights reserved.
//

#import "ViewController.h"
#import "LeCYCircleScrollView.h"

@interface ViewController () <LeCYCircleScrollViewDataSource, LeCYCircleScrollViewDelegate>
@property (nonatomic, strong) LeCYCircleScrollView *circelScrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) NSMutableArray *items;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:10];
    
    for (NSInteger i = 0; i < 2; i ++) {
        UIImage *name = [UIImage imageNamed:[NSString stringWithFormat:@"%ld", (long)i]];
        [items addObject:name];
    }
    
    self.items = items;
    
    [self.view addSubview:self.circelScrollView];
    [self.circelScrollView reloadData];
    
    [self.view addSubview:self.pageControl];
    self.pageControl.numberOfPages = self.items.count;
}

- (LeCYCircleScrollView *)circelScrollView
{
    if (!_circelScrollView) {
        LeCYCircleViewFlowLayout *flowLayout = [[LeCYCircleViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(300, 193);
        flowLayout.minimumLineSpacing = 3;
        flowLayout.itemScale = 0.95;
        flowLayout.alphaScale = 0.6;
        _circelScrollView = [[LeCYCircleScrollView alloc] initWithFrame:CGRectMake(0, 20, 375, 220) collectionViewLayout:flowLayout];
        _circelScrollView.dataSource = self;
        _circelScrollView.delegate = self;
        _circelScrollView.autoCircleScroll = YES;
        _circelScrollView.timeInterval = 2;
        
        [_circelScrollView registerClass:[UICollectionViewCell class] identifier:@"MY"];
    }
    return _circelScrollView;
}

- (UIPageControl *)pageControl
{
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 220, 375, 20)];
    }
    return _pageControl;
}

- (NSInteger)numberOfItemsInCircleScrollView:(LeCYCircleScrollView *)circleScrollView
{
    return self.items.count;
}

- (UICollectionViewCell *)circleScrollView:(LeCYCircleScrollView *)circleScrollView cellForItemAtIndex:(NSInteger)index
{
    UICollectionViewCell *cell = [circleScrollView dequeueIdentifier:@"MY" forIndex:index];
    cell.backgroundColor = [UIColor yellowColor];
    
    if (![cell.contentView viewWithTag:11]) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.contentView.bounds];
        imageView.tag = 11;
        [cell.contentView addSubview:imageView];
    }
    
    UIImageView *imageView = [cell.contentView viewWithTag:11];
    imageView.image = self.items[index];
    //[UIImage imageNamed:[NSString stringWithFormat:@"img_0%ld",indexPath.item + 1]];

    if (![cell.contentView viewWithTag:10]) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:cell.contentView.bounds];
        titleLabel.tag = 10;
        [cell.contentView addSubview:titleLabel];
    }
    UILabel *titleLabel = [cell.contentView viewWithTag:10];
    titleLabel.text = [NSString stringWithFormat:@"%ld", (long)index];
    return cell;
}

- (void)circleScrollView:(LeCYCircleScrollView *)circleScrollView didSelectItemAtIndex:(NSInteger)index
{
    NSLog(@"didSelectItemAtIndex %ld", (long)index);
}

- (void)circleScrollView:(LeCYCircleScrollView *)circleScrollView displayCellAtIndex:(NSInteger)index
{
    NSLog(@"displayCellAtIndex %ld", (long)index);
    self.pageControl.currentPage = index;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
