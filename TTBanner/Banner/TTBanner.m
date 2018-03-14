//
//  TTBanner.m
//  TTBanner
//
//  Created by wangd on 2018/3/11.
//  Copyright © 2018年 wangd. All rights reserved.
//

#import "TTBanner.h"

#import "TTBannerCell.h"
#import "TTTimer.h"
#import "TTPageControl.h"

static NSString * const kBannerCell = @"BannerCell";

@interface TTBanner ()
<UICollectionViewDataSource,
UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) TTTimer *timer;
@property (nonatomic, assign) NSInteger itemCount;
@property (nonatomic, strong) TTPageControl *pageControl;

@end

@implementation TTBanner

@synthesize autoScroll = _autoScroll;
@synthesize scrollInterval = _scrollInterval;
@synthesize shouldLoop = _shouldLoop;

@synthesize pageControlTintColor = _pageControlTintColor;
@synthesize pageControlCurrentTintColor = _pageControlCurrentTintColor;

- (void)dealloc {
    
    [self destroyTimer];
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        _itemCount = 0;
        _scrollInterval = 3;
        _autoScroll = YES;
        _shouldLoop = YES;
        
        [self addSubview:self.collectionView];
        [self addSubview:self.pageControl];
    }
    
    return self;
}

- (void)didMoveToSuperview {
    
    [super didMoveToSuperview];
    
    [self reloadData];  //首次被加载到父视图，自身刷新数据。
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (self.shouldLoop) {
        return self.itemCount > 1 ? self.itemCount + 2 : self.itemCount;
    }else {
        return self.itemCount;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    TTBannerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kBannerCell
                                                                   forIndexPath:indexPath];
    
    NSInteger item = indexPath.item;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(banner:viewForItemAtIndex:)]) {
        if (self.shouldLoop && self.itemCount > 1) {
            if (item == self.itemCount + 1) {
                item = 1;
            }else if (item == 0) {
                item = self.itemCount;
            }
            
            item = item - 1;
        }
        
        cell.itemView = [self.dataSource banner:self viewForItemAtIndex:item];
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(banner:didSelectedAtIndex:)]) {
        NSInteger item = indexPath.item;
        if (self.shouldLoop && self.itemCount > 1) {
            if (item == self.itemCount + 1) {
                item = 1;
            }else if (item == 0) {
                item = self.itemCount;
            }
            
            item = item - 1;
        }
        
        [self.delegate banner:self didSelectedAtIndex:item];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    NSInteger item = scrollView.contentOffset.x / [UIScreen mainScreen].bounds.size.width;
    
    if (self.shouldLoop && self.itemCount > 1) {
        if (item == self.itemCount + 1) {
            item = 1;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.collectionView
                 scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:item inSection:0]
                 atScrollPosition:UICollectionViewScrollPositionRight
                 animated:NO];
            });
        }else if (item == 0) {
            item = self.itemCount;
            if (scrollView.contentOffset.x < 20) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.collectionView
                     scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:item inSection:0]
                     atScrollPosition:UICollectionViewScrollPositionRight
                     animated:NO];
                });
            }
        }
    }
    
    if (self.shouldLoop && self.itemCount > 1) {
        self.pageControl.currentPage = item - 1;
    }else {
        self.pageControl.currentPage = item;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    [self suspendAutoScroll];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    [self resumeAutoScroll];
}

#pragma mark - Public Methods

- (void)reloadData {
    
    if (!self.dataSource) return;
    if ([self.dataSource respondsToSelector:@selector(numberOfItemsInBanner:)]) {
        self.itemCount = [self.dataSource numberOfItemsInBanner:self];
    }
    if (self.itemCount == 0) return;
    
    self.pageControl.numberOfPage = self.itemCount;
    [self.collectionView reloadData];
    
    if (self.shouldLoop && self.itemCount > 1) {
        [self.collectionView
         scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]
         atScrollPosition:UICollectionViewScrollPositionRight
         animated:NO];
    }
    
    [self timerTick];
}

- (void)resumeAutoScroll {
    
    if (self.autoScroll) {
        [self.timer resume];
    }
}

- (void)suspendAutoScroll {
    
    if (self.autoScroll) {
        [self.timer suspend];
    }
}

#pragma mark - Private Method

- (void)timerTick {
    
    [self destroyTimer];
    
    if (!self.autoScroll) {
        return;
    }
    
    if (self.itemCount < 2) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [self.timer tickProgress:^{
        [weakSelf autoScrollToNextItem];
    }];
}

- (void)destroyTimer {
    
    [self.timer destroy];
    self.timer = nil;
}

- (void)autoScrollToNextItem {
    
    NSInteger item = self.collectionView.indexPathsForVisibleItems.firstObject.item + 1;
    if (self.shouldLoop && self.itemCount > 1) {
        if (item > self.itemCount + 1) {
            item = self.itemCount + 1;
        }
    }else {
        if (item > self.itemCount - 1) {
            item = self.itemCount - 1;
        }
    }
    
    [self.collectionView
     scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:item inSection:0]
     atScrollPosition:UICollectionViewScrollPositionRight
     animated:YES];
}

#pragma mark - Setter

- (void)setAutoScroll:(BOOL)autoScroll {
    
    _autoScroll = autoScroll;
    [self timerTick];
}

- (void)setScrollInterval:(NSInteger)scrollInterval {
    
    _scrollInterval = scrollInterval;
    
    self.timer.tickInterval = self.scrollInterval;
    [self timerTick];
}

- (void)setShouldLoop:(BOOL)shouldLoop {
    
    _shouldLoop = shouldLoop;
    
    [self reloadData];
}

- (void)setPageControlTintColor:(UIColor *)pageControlTintColor {
    
    _pageControlTintColor = pageControlTintColor;
    self.pageControl.pageTintColor = self.pageControlTintColor;
}

- (void)setPageControlCurrentTintColor:(UIColor *)pageControlCurrentTintColor {
    
    _pageControlCurrentTintColor = pageControlCurrentTintColor;
    self.pageControl.currentPageTintColor = self.pageControlCurrentTintColor;
}

#pragma mark - Getter

- (UICollectionView *)collectionView {
    
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing = 0;
        flowLayout.itemSize = self.bounds.size;
        flowLayout.sectionInset = UIEdgeInsetsZero;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds
                                             collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.pagingEnabled = YES;
        _collectionView.alwaysBounceHorizontal = YES;
        _collectionView.scrollsToTop = NO;  //防止与其他滚动视图回到顶部的手势冲突
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        
        [_collectionView registerClass:[TTBannerCell class] forCellWithReuseIdentifier:kBannerCell];
    }
    
    return _collectionView;
}

- (TTTimer *)timer {
    
    if (!_timer) {
        _timer = [[TTTimer alloc] init];
        _timer.tickInterval = self.scrollInterval;
    }
    
    return _timer;
}

- (TTPageControl *)pageControl {
    
    if (!_pageControl) {
        CGFloat pageControlW = self.frame.size.width;
        CGFloat pageControlH = 32.0;
        CGFloat pageControlX = 0;
        CGFloat pageControlY = self.frame.size.height - pageControlH;
        _pageControl = [[TTPageControl alloc] initWithFrame:CGRectMake(pageControlX,
                                                                       pageControlY,
                                                                       pageControlW,
                                                                       pageControlH)];
        
        _pageControl.userInteractionEnabled = NO;
        _pageControl.autoresizingMask = UIViewAutoresizingNone;
    }
    
    return _pageControl;
}

@end
