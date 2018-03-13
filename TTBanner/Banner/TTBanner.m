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
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.itemCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    TTBannerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kBannerCell
                                                                   forIndexPath:indexPath];
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(banner:viewForItemAtIndex:)]) {
        cell.itemView = [self.dataSource banner:self viewForItemAtIndex:indexPath.item];
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(banner:didSelectAtIndex:)]) {
        [self.delegate banner:self didSelectAtIndex:indexPath.item];
    }
}

#pragma mark - UIScrollViewDelegate

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
    
    NSInteger currentIndex = self.collectionView.indexPathsForVisibleItems.firstObject.item;
    NSInteger index = currentIndex + 1;
    if (index >= self.itemCount) {
        index = 0;
    }
    
    BOOL animated = YES;
    if (index == 0) {
        animated = NO;
    }
    
    [self.collectionView
     scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]
     atScrollPosition:UICollectionViewScrollPositionRight
     animated:animated];
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
