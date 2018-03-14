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

static NSString * const kBannerCell = @"BannerCell";

@interface TTBanner ()
<UICollectionViewDataSource,
UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) TTTimer *timer;
@property (nonatomic, assign) NSInteger itemCount;

@end

@implementation TTBanner

@synthesize autoScroll = _autoScroll;
@synthesize scrollInterval = _scrollInterval;
@synthesize shouldLoop = _shouldLoop;

- (void)dealloc {
    
    [self destoryTimer];
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        _itemCount = 0;
        _scrollInterval = 3;
        _autoScroll = YES;
        _shouldLoop = YES;
        
        [self addSubview:self.collectionView];
    }
    
    return self;
}

- (void)didMoveToSuperview {
    
    [super didMoveToSuperview];
    
    [self reloadData];  //首次被加载到父视图，自身刷新数据。
    
    if (self.shouldLoop && self.itemCount > 1) {
        [self.collectionView
         scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]
         atScrollPosition:UICollectionViewScrollPositionRight
         animated:NO];
    }
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
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(banner:didSelectAtIndex:)]) {
        NSInteger item = indexPath.item;
        if (self.shouldLoop && self.itemCount > 1) {
            if (item == self.itemCount + 1) {
                item = 1;
            }else if (item == 0) {
                item = self.itemCount;
            }
            
            item = item - 1;
        }
        
        [self.delegate banner:self didSelectAtIndex:item];
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
    
    [self.collectionView reloadData];
    
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
    
    [self destoryTimer];
    
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

- (void)destoryTimer {
    
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
        _collectionView.scrollsToTop = NO;
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

@end
