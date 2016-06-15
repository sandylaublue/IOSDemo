//
//  HMNewsViewController.m
//  01-无限滚动
//
//  Created by apple on 14-7-29.
//  Copyright (c) 2014年 heima. All rights reserved.
//

#import "HMNewsViewController.h"
#import "HMNewsCell.h"
#import "MJExtension.h"
#import "HMNews.h"

#define HMCellIdentifier @"news"
#define HMMaxSections 1000

@interface HMNewsViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property (nonatomic, strong) NSArray *newses;

@property (nonatomic, strong) NSTimer* timer;
@end

@implementation HMNewsViewController


- (NSArray *)newses
{
    if (_newses == nil) {
        self.newses = [HMNews objectArrayWithFilename:@"newses.plist"];
        self.pageControl.numberOfPages = self.newses.count;
    }
    return _newses;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 注册cell
    [self.collectionView registerNib:[UINib nibWithNibName:@"HMNewsCell" bundle:nil] forCellWithReuseIdentifier:HMCellIdentifier];
    
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:HMMaxSections/2] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    
    [self addNSTimer];
}

-(void)addNSTimer
{
    NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(nextPage) userInfo:nil repeats:YES];
    //添加到runloop中
    [[NSRunLoop mainRunLoop]addTimer:timer forMode:NSRunLoopCommonModes];
    self.timer = timer;
}

- (void)removeTimer
{
    [self.timer invalidate];
    self.timer = nil;
}

-(NSIndexPath *)resetIndexPath
{
    NSIndexPath *currentIndexPath = [[self.collectionView indexPathsForVisibleItems]lastObject];
    
    NSIndexPath *currentIndexPathReset = [NSIndexPath indexPathForItem:currentIndexPath.item inSection:HMMaxSections/2];
   
    [self.collectionView scrollToItemAtIndexPath:currentIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    
    return currentIndexPathReset;
}

-(void)nextPage
{
    //1）获取当前正在展示的位置
    NSIndexPath *currentIndexPath=[[self.collectionView indexPathsForVisibleItems]lastObject];
    
    //2）计算出下一个需要展示的位置
    NSInteger nextItem=currentIndexPath.item+1;
    NSInteger nextSection=currentIndexPath.section;
    if (nextItem==self.newses.count) {
            nextItem=0;
            nextSection++;
        }
      NSIndexPath *nextIndexPath=[NSIndexPath indexPathForItem:nextItem inSection:nextSection];
    
    //3）通过动画滚动到下一个位置
         [self.collectionView scrollToItemAtIndexPath:nextIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
}





#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.newses.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return HMMaxSections;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HMNewsCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:HMCellIdentifier forIndexPath:indexPath];
    
    cell.news = self.newses[indexPath.item];
    
    return cell;
}


-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self removeTimer];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self addNSTimer];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //
    int page =  (int)(scrollView.contentOffset.x / scrollView.bounds.size.width + 0.5) % self.newses.count;
    self.pageControl.currentPage = page;
}

@end
